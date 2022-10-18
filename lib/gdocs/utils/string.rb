class String
  # to_s.camelize(:lower) - if we have ActiveSupport as dependency
  def camelize_lower
    split('_').inject([]){ |buffer, e| buffer + [buffer.empty? ? e : e.capitalize] }.join
  end
end
