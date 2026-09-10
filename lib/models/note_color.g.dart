// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_color.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteColorAdapter extends TypeAdapter<NoteColor> {
  @override
  final int typeId = 1;

  @override
  NoteColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteColor.jaune;
      case 1:
        return NoteColor.orange;
      case 2:
        return NoteColor.rose;
      case 3:
        return NoteColor.violet;
      case 4:
        return NoteColor.bleu;
      case 5:
        return NoteColor.vertClair;
      case 6:
        return NoteColor.vertFonce;
      case 7:
        return NoteColor.gris;
      case 8:
        return NoteColor.blanc;
      default:
        return NoteColor.jaune;
    }
  }

  @override
  void write(BinaryWriter writer, NoteColor obj) {
    switch (obj) {
      case NoteColor.jaune:
        writer.writeByte(0);
        break;
      case NoteColor.orange:
        writer.writeByte(1);
        break;
      case NoteColor.rose:
        writer.writeByte(2);
        break;
      case NoteColor.violet:
        writer.writeByte(3);
        break;
      case NoteColor.bleu:
        writer.writeByte(4);
        break;
      case NoteColor.vertClair:
        writer.writeByte(5);
        break;
      case NoteColor.vertFonce:
        writer.writeByte(6);
        break;
      case NoteColor.gris:
        writer.writeByte(7);
        break;
      case NoteColor.blanc:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
