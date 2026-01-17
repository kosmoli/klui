// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tool _$ToolFromJson(Map<String, dynamic> json) => _Tool(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  toolType: $enumDecodeNullable(_$ToolTypeEnumMap, json['tool_type']),
  sourceType: json['source_type'] as String?,
  sourceCode: json['source_code'] as String?,
  jsonSchema: json['json_schema'] as Map<String, dynamic>?,
  argsJsonSchema: json['args_json_schema'] as Map<String, dynamic>?,
  defaultRequiresApproval: json['default_requires_approval'] as bool?,
  enableParallelExecution: json['enable_parallel_execution'] as bool?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ToolToJson(_Tool instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'tool_type': _$ToolTypeEnumMap[instance.toolType],
  'source_type': instance.sourceType,
  'source_code': instance.sourceCode,
  'json_schema': instance.jsonSchema,
  'args_json_schema': instance.argsJsonSchema,
  'default_requires_approval': instance.defaultRequiresApproval,
  'enable_parallel_execution': instance.enableParallelExecution,
  'tags': instance.tags,
};

const _$ToolTypeEnumMap = {
  ToolType.custom: 'custom',
  ToolType.builtin: 'builtin',
  ToolType.mcp: 'mcp',
  ToolType.lettaClient: 'letta_client',
  ToolType.pythonFunction: 'python_function',
  ToolType.lettaSleeptimeCore: 'letta_sleeptime_core',
};
