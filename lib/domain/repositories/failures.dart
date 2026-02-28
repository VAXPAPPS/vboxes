import 'package:equatable/equatable.dart';

abstract class VmFailure extends Equatable {
  final String message;
  const VmFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LibraryNotLoadedFailure extends VmFailure {
  const LibraryNotLoadedFailure(super.message);
}

class NativeCallFailure extends VmFailure {
  const NativeCallFailure(super.message);
}

class VmNotFoundFailure extends VmFailure {
  const VmNotFoundFailure(String name)
      : super('Virtual machine "$name" not found');
}

class VmAlreadyRunningFailure extends VmFailure {
  const VmAlreadyRunningFailure(String name)
      : super('Virtual machine "$name" is already running');
}

class VmParseFailure extends VmFailure {
  const VmParseFailure(super.message);
}

class VmCreateFailure extends VmFailure {
  const VmCreateFailure(super.message);
}
