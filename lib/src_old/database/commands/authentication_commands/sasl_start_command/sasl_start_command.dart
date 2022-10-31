import 'dart:convert';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src_old/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src_old/database/message/additional/section.dart';
import 'package:mongo_dart/src_old/database/message/mongo_modern_message.dart';

import '../../../../network/connection.dart';

class SaslStartCommand extends CommandOperation {
  SaslStartCommand(Db db, String mechanism, Uint8List payload,
      {SaslStartOptions? saslStartOptions,
      Map<String, Object>? rawOptions,
      Connection? connection})
      : super(
            db, <String, Object>{...?saslStartOptions?.options, ...?rawOptions},
            command: <String, Object>{
              keySaslStart: 1,
              keyMechanism: mechanism,
              keyPayload: base64.encode(payload)
            },
            connection: connection);

  /*  @override
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async =>
      super.execute(skipStateCheck: true); */

  @override
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async {
    final db = this.db;

    var command = $buildCommand();
    processOptions(command);
    command.addAll(options);

    var message = MongoModernMessage(command);

    connection ??= db.masterConnectionAnyState;

    var response = await connection!.executeModernMessage(message);

    var section = response.sections.firstWhere((Section section) =>
        section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }
}
