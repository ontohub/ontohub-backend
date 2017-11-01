# frozen_string_literal: true

Types::MappingTypeEnum = GraphQL::EnumType.define do
  name 'MappingType'
  description 'Specifies the type of the Mapping'

  # TODO: Till, please review and supply descriptions.
  value 'local_def', ''
  value 'local_thm_open', ''
  value 'local_thm_proved', ''
  value 'global_def', ''
  value 'global_thm_open', ''
  value 'global_thm_proved', ''
  value 'hiding_def', ''
  value 'free_def', ''
  value 'cofree_def', ''
  value 'np_free_def', ''
  value 'minimize_def', ''
  value 'hiding_open', ''
  value 'hiding_proved', ''
  value 'hiding_free_open', ''
  value 'hiding_cofree_open', ''
  value 'hiding_np_free_open', ''
  value 'hiding_minimize_open', ''
  value 'hiding_free_proved', ''
  value 'hiding_cofree_proved', ''
  value 'hiding_np_free_proved', ''
  value 'hiding_minimize_proved', ''
end
