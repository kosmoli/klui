import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool.freezed.dart';
part 'tool.g.dart';

/// Tool type enum
enum ToolType {
  @JsonValue('custom')
  custom,
  @JsonValue('builtin')
  builtin,
  @JsonValue('mcp')
  mcp,
  @JsonValue('letta_client')
  lettaClient,
  @JsonValue('python_function')
  pythonFunction,
  @JsonValue('letta_sleeptime_core')
  lettaSleeptimeCore,
  @JsonValue('letta_builtin')
  lettaBuiltin,
  @JsonValue('letta_core')
  lettaCore,
  @JsonValue('letta_files_core')
  lettaFilesCore,
  @JsonValue('letta_memory_core')
  lettaMemoryCore,
  @JsonValue('letta_multi_agent_core')
  lettaMultiAgentCore,
  @JsonValue('letta_voice_sleeptime_core')
  lettaVoiceSleeptimeCore,
}

/// Tool model
@freezed
abstract class Tool with _$Tool {
  const Tool._();

  const factory Tool({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'tool_type') ToolType? toolType,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_code') String? sourceCode,
    @JsonKey(name: 'json_schema') Map<String, dynamic>? jsonSchema,
    @JsonKey(name: 'args_json_schema') Map<String, dynamic>? argsJsonSchema,
    @JsonKey(name: 'default_requires_approval') bool? defaultRequiresApproval,
    @JsonKey(name: 'enable_parallel_execution') bool? enableParallelExecution,
    List<String>? tags,
  }) = _Tool;

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
}
