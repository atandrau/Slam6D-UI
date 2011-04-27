module MatchingsHelper
  
  def figure_latex(sketchup)
    "\\includegraphics{models\/#{sketchup.google_id}.jpg}"
  end
end
