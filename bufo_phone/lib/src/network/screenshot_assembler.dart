import 'dart:typed_data';

class _ScreenshotAssembly {
  final List<Uint8List?> chunks;
  int chunksReceived = 0;
  DateTime lastUpdated = DateTime.now();
  bool isReady = false;


  _ScreenshotAssembly(int datagramCount)
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

class _ScreenshotChunk {
  final int screenshotId;
  final int index;
  final int chunksInScreenshot;
  final Uint8List jpegChunk;

  _ScreenshotChunk({
    required this.screenshotId,
    required this.jpegChunk,
    required this.index,
    required this.chunksInScreenshot,
  });

  @override
  String toString() {
    return 'id: $screenshotId, index: $index, chunkCount: $chunksInScreenshot';
  }
}


class ScreenshotAssembler {


  static const int _headerSize = 8;
  static const int _maxChunksPerScreenshot = 4000;

  final Map<int, _ScreenshotAssembly> _assemblyTargets = {};
  final int _maxOngoingAssemblies = 6;
  final void Function(Uint8List) _screenshotReadyCallback;

  ScreenshotAssembler(this._screenshotReadyCallback);

  void processScreenshotChunkData(Uint8List data){
    if(data.length < _headerSize){return;}
    

    final ByteData header = ByteData.sublistView(data.sublist(0, _headerSize));
    final int screenshotId = header.getInt32(0);
    final int chunkIndex = header.getUint16(4);
    final int chunksInScreenshot = header.getUint16(6);
    final Uint8List jpegChunk = data.sublist(_headerSize);

    if(chunksInScreenshot <= 0 || chunksInScreenshot > _maxChunksPerScreenshot || chunkIndex > chunksInScreenshot){
      return;
    } 
    _processChunk(
      _ScreenshotChunk(
        screenshotId: screenshotId, 
        jpegChunk: jpegChunk, 
        index: chunkIndex, 
        chunksInScreenshot: chunksInScreenshot
      ),
      
    );

  }  

  void _processChunk(_ScreenshotChunk chunk){

    if(_assemblyTargets.containsKey(chunk.screenshotId)){
      _ScreenshotAssembly assemblyTarget = _assemblyTargets[chunk.screenshotId]!;
      if(chunk.chunksInScreenshot != assemblyTarget.chunks.length){
        _assemblyTargets.remove(chunk.screenshotId);
        return;
      }

      if(assemblyTarget.chunks[chunk.index] != null){ return; }

      assemblyTarget.addChunk(chunk.jpegChunk, chunk.index);
      if(assemblyTarget.isReady){
        _handleAssemblyReady(chunk.screenshotId);
      }
      

      return;
    }
    if(_assemblyTargets.length >= _maxOngoingAssemblies){
      _removeLeastActiveAssembly();
    }
    _assemblyTargets[chunk.screenshotId] = _ScreenshotAssembly(chunk.chunksInScreenshot);
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
    _assemblyTargets.remove(assemblyId);
    
    _screenshotReadyCallback(bytesBuilder.takeBytes());
    
  }

  void _removeLeastActiveAssembly() {

    final MapEntry<int, _ScreenshotAssembly> leastActiveAssembly = _assemblyTargets.entries.reduce(
      (MapEntry<int, _ScreenshotAssembly> a, MapEntry<int, _ScreenshotAssembly> b) => a.value.lastUpdated.isBefore(b.value.lastUpdated) ? a : b,
    );
    _assemblyTargets.remove(leastActiveAssembly.key);
  }
}
