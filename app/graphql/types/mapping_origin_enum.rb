# frozen_string_literal: true

Types::MappingOriginEnum = GraphQL::EnumType.define do
  name 'MappingOrigin'
  description 'Specifies the origin of the Mapping'

  # TODO: Till, please review and supply descriptions.
  value 'see_target', ''
  value 'see_source', ''
  value 'test', ''
  value 'dg_link_verif', ''
  value 'dg_implies_link', ''
  value 'dg_link_extension', ''
  value 'dg_link_translation', ''
  value 'dg_link_closed_lenv', ''
  value 'dg_link_imports', ''
  value 'dg_link_intersect', ''
  value 'dg_link_morph', ''
  value 'dg_link_inst', ''
  value 'dg_link_inst_arg', ''
  value 'dg_link_view', ''
  value 'dg_link_align', ''
  value 'dg_link_fit_view', ''
  value 'dg_link_fit_view_imp', ''
  value 'dg_link_proof', ''
  value 'dg_link_flattening_union', ''
  value 'dg_link_flattening_rename', ''
  value 'dg_link_refinement', ''
end
