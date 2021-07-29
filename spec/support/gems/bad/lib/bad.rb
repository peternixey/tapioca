# typed: true
# frozen_string_literal: true

module Bad
  PI = 3.1415

  def self.bar(a = 1, b: 2, **opts)
    number = opts[:number] || 0
    39 + a + b + number
  end

  def self.failure
    raise RuntimeError
  end
end
