# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks the indentation of the first element in a parenthesized expression
      # where the opening parenthesis and the first element are on separate lines.
      # The other elements' indentations are handled by the AlignArray cop.
      class IndentMethodParameters < Cop
        include Alignment
        include ConfigurableEnforcedStyle
        include ArrayHashIndentation

        MSG = 'Use %<configured_indentation_width>d spaces for indentation ' \
              'in method args, relative to %<base_description>s.'.freeze

        def on_def(node)
          return if node.arguments.empty?
          return if node.arguments.loc.begin.nil?
          check(node)
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, @column_delta)
        end

        private

        def brace_alignment_style
          :align_parentheses
        end

        def check(def_node)
          return if ignored_node?(def_node)

          left_parenthesis = def_node.arguments.loc.begin
          first_elem = def_node.arguments.first
          if first_elem
            return if first_elem.source_range.line == left_parenthesis.line

            check_first(first_elem, left_parenthesis, nil, 0)
          end
        end

        # Returns the description of what the correct indentation is based on.
        def base_description(_)
          if style == brace_alignment_style
            'the position of the opening parenthesis'
          else
            'the start of the line where the left parenthesis is'
          end
        end

        def message(base_description)
          format(
            MSG,
            configured_indentation_width: configured_indentation_width,
            base_description: base_description
          )
        end
      end
    end
  end
end
