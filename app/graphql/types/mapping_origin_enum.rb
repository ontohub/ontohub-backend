# frozen_string_literal: true

Types::MappingOriginEnum = GraphQL::EnumType.define do
  name 'MappingOrigin'
  description 'Specifies the origin (in the DOL document) of the Mapping'

  value 'see_target', 'that of the source OMS of the mapping'
  value 'see_source', 'that of the target OMS of the mapping'
  value 'test', 'used for testing purposes'
  value 'dg_link_verif', 'development graph calculus'
  value 'dg_implies_link', 'implied extension'
  value 'dg_link_extension', 'extension OMS'
  value 'dg_link_translation', 'translation OMS'
  value 'dg_link_closed_lenv', 'closure OMS'
  value 'dg_link_imports', 'CASL imports'
  value 'dg_link_intersect', 'intersection'
  value 'dg_link_morph', 'morphism created during an instantiation of a parameterised OMS (CASL syntax)'
  value 'dg_link_inst', 'reference to an OMS'
  value 'dg_link_inst_arg', 'argument of a parameterised OMS (CASL syntax)'
  value 'dg_link_view', 'interpretation (view)'
  value 'dg_link_align', 'alignment'
  value 'dg_link_fit_view', 'fitting view on an instantiation of a parameterised OMS (CASL syntax)'
  value 'dg_link_fit_view_imp', 'implict fitting view on an instantiation of a parameterised OMS (CASL syntax)'
  value 'dg_link_proof', 'proof within the development graph calculus'
  value 'dg_link_flattening_union', 'flattening of an OMS union'
  value 'dg_link_flattening_rename', 'flattening of an OMS translation'
  value 'dg_link_refinement', 'refinement of OMS'
end
