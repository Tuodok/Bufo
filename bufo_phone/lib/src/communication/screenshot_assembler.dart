import 'dart:async';
import 'dart:typed_data';


class ScreenshotAssembly {
  final List<Uint8List?> chunks;
  int chunksReceived = 0;
  int totalBytes = 0;
  DateTime lastUpdated = DateTime.now();
  bool isReady = false;


  ScreenshotAssembly(int datagramCount)
    :chunks = List<Uint8List?>.filled(datagramCount, null);
  
  void addChunk(Uint8List data, int index){
    chunks[index] = data;
    chunksReceived ++;
    lastUpdated = DateTime.now();
    if(chunksReceived >= chunks.length ){

      isReady = true;
    }
  }
}

class ScreenshotChunk {
  final int screenshotId;
  final int index;
  final int chunksInScreenshot;
  final Uint8List jpegChunk;

  ScreenshotChunk({
    required this.screenshotId,
    required this.jpegChunk,
    required this.index,
    required this.chunksInScreenshot,
  });
}


class ScreenshotAssembler {

  final Map<int, ScreenshotAssembly> _assemblyTargets = {};
  final int _maxOngoingAssemblies = 6;

  final StreamController<Uint8List> _streamController = StreamController<Uint8List>();

  Stream<Uint8List> get screenshotStream => _streamController.stream; 

  

  void processChunk(ScreenshotChunk chunk){
    if(_assemblyTargets.containsKey(chunk.screenshotId)){
      ScreenshotAssembly assemblyTarget = _assemblyTargets[chunk.screenshotId]!;
      if(chunk.chunksInScreenshot != assemblyTarget.chunks.length){
        _assemblyTargets.remove(chunk.screenshotId);
        return;
      }

      if(assemblyTarget.chunks[chunk.index] == null){ return; }

      assemblyTarget.addChunk(chunk.jpegChunk, chunk.index);
      if(assemblyTarget.isReady){
        _handleAssemblyReady(chunk.screenshotId);
      }
      

      return;
    }
    if(_assemblyTargets.length >= _maxOngoingAssemblies){
      _removeLeastActiveAssembly();
    }
    _assemblyTargets[chunk.screenshotId] = ScreenshotAssembly(chunk.chunksInScreenshot);
    _assemblyTargets[chunk.screenshotId]!.addChunk(chunk.jpegChunk, chunk.index);
    if(_assemblyTargets[chunk.screenshotId]!.isReady){
      _handleAssemblyReady(chunk.screenshotId);
    }
      
    
  
  }

  void _handleAssemblyReady(int assemblyId){
    BytesBuilder bytesBuilder = BytesBuilder(copy: false);
    for(Uint8List? chunk in _assemblyTargets[assemblyId]!.chunks){
      bytesBuilder.add(chunk!);
    }
    _streamController.sink.add(bytesBuilder.takeBytes());
    _assemblyTargets.remove(assemblyId);
  }

  void _removeLeastActiveAssembly() {

    final MapEntry<int, ScreenshotAssembly> leastActiveAssembly = _assemblyTargets.entries.reduce(
      (a, b) => a.value.lastUpdated.isBefore(b.value.lastUpdated) ? a : b,
    );
    _assemblyTargets.remove(leastActiveAssembly.key);
  }
}
