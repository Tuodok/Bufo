import 'dart:typed_data';

class Screenshot {
  final List<Uint8List?> chunks;
  int chunksReceived = 0;
  int totalBytes = 0;


  Screenshot(int datagramCount)
    :chunks = List<Uint8List?>.filled(datagramCount, null);
  
  bool addChunk(Uint8List data, int index){
    chunks[index] = data;
    chunksReceived ++;
    if(chunksReceived >= chunks.length ){
      return true;
    }
    return false;
  }
}