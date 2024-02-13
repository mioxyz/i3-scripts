#!/usr/bin/env ruby
#require 'thread'

# Define the Greek characters and their English word equivalents
characters = [
  "ρ roh", "α alpha", "β beta", "γ gamma", "δ delta", "ε epsilon", "ζ zeta", "η eta", "θ theta", "ι iota", "κ kappa", "λ lambda", "μ mu", "ξ xi",
  "π pi", "ς sigma_final", "τ tau", "φ phi", "χ chi", "ψ psi", "ω omega", "Γ Gamma", "Δ Delta", "Θ Theta", "Λ Lambda", "Ξ Xi",
  "Π Pi", "Σ Sigma", "Φ Phi", "Ψ Psi", "Ω Omega", "ϴ Theta_symbol", "∊ element of", "⋂ intersection", "⋃ union", "⋀ and", "⋁ or", "⊂ subset", "⊃ subset", "⊄ not subset", "⊆ proper subset", "⊇ proper subset", "∫ integral", "ℕ natural number", "ℚ rational number", "ℝ real number", "ℰ fancy e", "· cdot", "≤ leq", "≥ geq", "∘ compose", "ℂ imaginary number", "ℤ integer whole number"
]

# Use dmenu to select a character
selected = IO.popen('echo "' + characters.join("\n") + '" | dmenu -i -l 12 -fn Consolas-22').read.strip

# Extract the Greek character from the selected option
char = selected.split(' ')[0]

# Define a thread that sends the Greek character as a keystroke after a delay
#send_key_thread = Thread.new do
  # sleep 0.05
  system("xdotool type --clearmodifiers #{char}")
#end

# Wait for the thread to finish
#send_key_thread.join
