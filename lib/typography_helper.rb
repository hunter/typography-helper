# TypographyHelper
# basic typographical substitutions by luke hartman <http://mrturtle.com>

module TypographyHelper

	# converts a & surrounded by optional whitespace or a non-breaking space
	# to the HTML entity and surrounds it in a span with a styled class
	def amp(text)
		# $1 is an excluded HTML tag, $2 is the part before the caps and $3 is the amp match
		text.gsub(/<(code|pre).+?<\/\1>|(\s|&nbsp;)&(\s|&nbsp;)/) {|str|
		$1 ? str : $2 + '<span class="amp">&amp;</span>' + $3 }
	end

	# based on http://mucur.name/posts/widon-t-and-smartypants-helpers-for-rails
	# original concept from http://shauninman.com/archive/2006/08/22/widont_wordpress_plugin
	#
	# replaces space(s) before the last word (or tag before the last word)
	# before an optional closing element (a, em, span, strong) 
	# before a closing tag (p, h[1-6], li, dt, dd) or the end of the string
	def widont(text)
		text.gsub(%r/
			(\s+)																			# some whitespace group 1
			(																					# capture group 2
				(<(a|em|span|strong)[^>]*?>\s*)?				# an optional opening tag followed by optional spaces
				[^<>\s]+																# the matched word itself
				(?:<\/(a|em|span|strong)[^>]*?>\s*)*		# zero or more inline closing tags followed by zero or more spaces
				(?:<\/(p|h[1-6]|li|dt|dd)|$)						# a closing element or end of line
			/x, '&nbsp;\2')
	end

	# speedier method for one-line elements only (if you care about performance)
	# taken from http://mucur.name/posts/widon-t-and-smartypants-helpers-for-rails
	def widont_single(text)
		text.strip!
		text[text.rindex(' '), 1] = '&nbsp;' if text.rindex(' ')
		text
	end

	# surrounds two or more consecutive captial letters, perhaps with interspersed digits and periods
	# in a span with a styled class
	def caps(text)
		# $1 is an excluded HTML tag, $2 is the part before the caps and $3 is the caps match
		text.gsub(/<(code|pre).+?<\/\1>|(\s|&nbsp;|^|'|")([A-Z][A-Z\d\.]{1,})(?!\w)/) {|str|
		$1 ? str : $2 + '<span class="caps">' + $3 + '</span>' }
	end

	# encloses initial single or double quote, or their entities
	# (optionally preceeded by a block element and perhaps an inline element)
	# with a span that can be styled
	def initial_quotes(text)
		# $1 is the initial part of the string, $2 is the quote or entitity, and $3 is the double quote
		text.gsub(/((?:<(?:h[1-6]|p|li|dt|dd)[^>]*>|^)\s*(?:<(?:a|em|strong|span)[^>]*>)?)('|&#8216;|("|&#8220;))/) {$1 + "<span class=\"#{'d' if $3}quo\">#{$2}</span>"}
	end

	# uses RubyPants to transform various typographical thingys to proper HTML entities
	# requires the RubyPants gem http://www.gemjack.com/gems/rubypants-0.2.0/classes/RubyPants.html
	# Based on SmartyPants http://daringfireball.net/projects/smartypants
	def rubypants(text)
		require 'rubygems'
		require 'rubypants'
		RubyPants.new(text).to_html
	end
	
	# main function to do all the functions from the method
	def rubyshirt(text)
		initial_quotes amp(caps(widont(text)))
	end
	
	# function to perform rubyshirt and rubypants
	def rubyoutfit(text)
		rubyshirt rubypants(text)
	end
	
	# perform the Rails safe-proofing filter and then perform the typography filters
	def th(text)
		rubyoutfit(h(text))
	end
	
	# alias the rubyshirt method to make views cleaner
	alias_method :t, :rubyoutfit

end