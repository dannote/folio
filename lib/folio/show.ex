defmodule Folio.Show do
  @moduledoc """
  Apply show rules to content trees before compilation.

  Show rules emulate Typst's `#show` mechanism by transforming
  matching content elements in Elixir before sending to Rust.

  They are applied bottom-up: children are transformed first,
  then the parent node is matched and replaced.

  Show rules found anywhere in the content tree are extracted
  and applied globally. Place them at the top level for clarity.
  """

  alias Folio.Content

  @doc """
  Extract all show rules from the content tree and apply them.

  Returns the transformed content with all show rules removed.
  """
  @spec apply([Content.t()]) :: [Content.t()]
  def apply(content) when is_list(content) do
    {rules, stripped} = extract_rules(content)
    apply_transforms(stripped, rules)
  end

  # ── Extraction ────────────────────────────────────────────────────────────

  defp extract_rules(nodes) when is_list(nodes) do
    {rules, stripped} =
      Enum.reduce(nodes, {[], []}, fn node, {rs, ns} ->
        case node do
          %Content.ShowRule{} = rule -> {[{rule.target, rule.transform} | rs], ns}
          other -> {rs, [other | ns]}
        end
      end)

    {child_rules, cleaned} = extract_from_children(Enum.reverse(stripped))
    {Enum.reverse(rules) ++ child_rules, cleaned}
  end

  defp extract_from_children(nodes) when is_list(nodes) do
    {rules_acc, cleaned_acc} =
      Enum.reduce(nodes, {[], []}, fn node, {rs, ns} ->
        {child_rules, cleaned_node} = extract_from_node(node)
        {rs ++ child_rules, [cleaned_node | ns]}
      end)

    {rules_acc, Enum.reverse(cleaned_acc)}
  end

  defp extract_from_node(node) when is_struct(node) do
    child_fields = [:body, :children, :caption, :term, :description, :supplement]

    {all_rules, updated} =
      Enum.reduce(child_fields, {[], node}, fn field, {rs, n} ->
        case Map.get(n, field) do
          list when is_list(list) ->
            {child_rs, cleaned} = extract_rules(list)
            {rs ++ child_rs, Map.put(n, field, cleaned)}

          _ ->
            {rs, n}
        end
      end)

    {all_rules, updated}
  end

  defp extract_from_node(node), do: {[], node}

  # ── Application ───────────────────────────────────────────────────────────

  defp apply_transforms(nodes, rules) when is_list(nodes) do
    nodes
    |> Enum.flat_map(fn node -> apply_to_node(node, rules) end)
  end

  defp apply_to_node(%Content.ShowRule{}, _rules), do: []

  defp apply_to_node(node, rules) when is_struct(node) do
    node = transform_children(node, rules)

    case node_type(node) do
      nil ->
        [node]

      type ->
        case List.keyfind(rules, type, 0) do
          {^type, tx} -> Content.to_content(tx.(node))
          nil -> [node]
        end
    end
  end

  defp apply_to_node(node, _rules), do: [node]

  defp transform_children(node, rules) do
    child_fields = [:body, :children, :caption, :term, :description, :supplement]

    Enum.reduce(child_fields, node, fn field, n ->
      case Map.get(n, field) do
        list when is_list(list) -> Map.put(n, field, apply_transforms(list, rules))
        _ -> n
      end
    end)
  end

  # ── Node type mapping ─────────────────────────────────────────────────────

  defp node_type(%Content.Text{}), do: :text
  defp node_type(%Content.Space{}), do: :space
  defp node_type(%Content.Heading{}), do: :heading
  defp node_type(%Content.Cite{}), do: :cite
  defp node_type(%Content.Bibliography{}), do: :bibliography
  defp node_type(%Content.Paragraph{}), do: :paragraph
  defp node_type(%Content.Strong{}), do: :strong
  defp node_type(%Content.Emph{}), do: :emph
  defp node_type(%Content.Strike{}), do: :strike
  defp node_type(%Content.Underline{}), do: :underline
  defp node_type(%Content.Highlight{}), do: :highlight
  defp node_type(%Content.Super{}), do: :super
  defp node_type(%Content.Sub{}), do: :sub
  defp node_type(%Content.Smallcaps{}), do: :smallcaps
  defp node_type(%Content.Image{}), do: :image
  defp node_type(%Content.Figure{}), do: :figure
  defp node_type(%Content.Table{}), do: :table
  defp node_type(%Content.TableHeader{}), do: :table_header
  defp node_type(%Content.TableRow{}), do: :table_row
  defp node_type(%Content.TableCell{}), do: :table_cell
  defp node_type(%Content.Columns{}), do: :columns
  defp node_type(%Content.Colbreak{}), do: :colbreak
  defp node_type(%Content.Pagebreak{}), do: :pagebreak
  defp node_type(%Content.Parbreak{}), do: :parbreak
  defp node_type(%Content.Linebreak{}), do: :linebreak
  defp node_type(%Content.Math{}), do: :math
  defp node_type(%Content.Link{}), do: :link
  defp node_type(%Content.Raw{}), do: :raw
  defp node_type(%Content.Quote{}), do: :quote
  defp node_type(%Content.List{}), do: :list
  defp node_type(%Content.ListItem{}), do: :list_item
  defp node_type(%Content.EnumList{}), do: :enum
  defp node_type(%Content.EnumItem{}), do: :enum_item
  defp node_type(%Content.Label{}), do: :label
  defp node_type(%Content.Ref{}), do: :ref
  defp node_type(%Content.Align{}), do: :align
  defp node_type(%Content.Block{}), do: :block
  defp node_type(%Content.Hide{}), do: :hide
  defp node_type(%Content.Repeat{}), do: :repeat
  defp node_type(%Content.Place{}), do: :place
  defp node_type(%Content.VSpace{}), do: :vspace
  defp node_type(%Content.HSpace{}), do: :hspace
  defp node_type(%Content.Pad{}), do: :pad
  defp node_type(%Content.Stack{}), do: :stack
  defp node_type(%Content.Rect{}), do: :rect
  defp node_type(%Content.Square{}), do: :square
  defp node_type(%Content.Circle{}), do: :circle
  defp node_type(%Content.Ellipse{}), do: :ellipse
  defp node_type(%Content.Line{}), do: :line
  defp node_type(%Content.Polygon{}), do: :polygon
  defp node_type(%Content.Outline{}), do: :outline
  defp node_type(%Content.Title{}), do: :title
  defp node_type(%Content.TermList{}), do: :term_list
  defp node_type(%Content.TermItem{}), do: :term_item
  defp node_type(%Content.Footnote{}), do: :footnote
  defp node_type(%Content.Divider{}), do: :divider
  defp node_type(%Content.Grid{}), do: :grid
  defp node_type(%Content.GridCell{}), do: :grid_cell
  defp node_type(%Content.LocalSet{}), do: :local_set
  defp node_type(%Content.RawTypst{}), do: :raw_typst
  defp node_type(%Content.Sequence{}), do: :sequence
  defp node_type(%Content.ShowRule{}), do: :show_rule
  defp node_type(_), do: nil
end
