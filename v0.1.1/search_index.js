var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API","title":"API","text":"Modules = [Turkie]","category":"page"},{"location":"api/#Turkie.TurkieCallback","page":"API","title":"Turkie.TurkieCallback","text":"TurkieCallback(model::DynamicPPL.Model, plots::Series/AbstractVector; window=1000, kwargs...)\n\nKeyword arguments\n\nwindow=1000 : Use a window for plotting the trace\n\n\n\n\n\n","category":"type"},{"location":"#Turkie.jl","page":"Home","title":"Turkie.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Turkie.jl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Docs Latest) (Image: Docs Stable)","category":"page"},{"location":"","page":"Home","title":"Home","text":"A Julia package for vizualizing dynamically sampling and statistics of Bayesian models ***","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Turkie is a registered package and is symply installed by running","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add Turkie","category":"page"},{"location":"#Basic-example-with-Turing","page":"Home","title":"Basic example with Turing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Right now Turkie only works with Turing.jl but it should be compatible with any sampling algorithm following the AbstractMCMC.jl interface","category":"page"},{"location":"","page":"Home","title":"Home","text":"Here is a simple example to start right away :","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Turing\nusing Turkie\nusing Makie # You could also use CairoMakie or another backend\n@model function demo(x) # Some random Turing model\n    m0 ~ Normal(0, 2)\n    s ~ InverseGamma(2, 3)\n    m ~ Normal(m0, √s)\n    for i in eachindex(x)\n        x[i] ~ Normal(m, √s)\n    end\nend\n\nxs = randn(100) .+ 1 # Create some random data\nm = demo(xs) # Create the model\ncb = TurkieCallback(m) # Create a callback function to be given to the sample\nchain = sample(m, NUTS(0.65), 300; callback = cb) # Sample and plot at the same time","category":"page"},{"location":"","page":"Home","title":"Home","text":"You should observe something like this :","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Turkie Video)","category":"page"},{"location":"#The-example-in-details","page":"Home","title":"The example in details","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If we look at the last 2 steps:","category":"page"},{"location":"","page":"Home","title":"Home","text":"c = TurkieCallback(m)","category":"page"},{"location":"","page":"Home","title":"Home","text":"will create a Makie window and store the names of all the (non-observed) variables of m. By default the quantities looked at for each of the variables are :","category":"page"},{"location":"","page":"Home","title":"Home","text":"A combination of an histogram and a KDE approximation\nThe sample mean\nThe sample variance\nThe auto-covariance of the samples","category":"page"},{"location":"","page":"Home","title":"Home","text":"Next :","category":"page"},{"location":"","page":"Home","title":"Home","text":"chain = sample(m, NUTS(0.65), 300; callback = cb) ","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is your typical posterior sampling with Turing.jl. While sampling the callback object cb will be called and the statistics will be updated live.","category":"page"},{"location":"#Tuning-the-quantities","page":"Home","title":"Tuning the quantities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Of course the default is not always desirable. You can chose what variables and what quantities are shown by giving a Dict to TurkieCallback instead of a model. For example,","category":"page"},{"location":"","page":"Home","title":"Home","text":"cb = TurkieCallback(Dict(:v => [:trace, :mean],\n                        :s => [:autocov, :var]))","category":"page"},{"location":"","page":"Home","title":"Home","text":"will only show the trace and the sample mean of v and the auto-covariance and variance of s. Pairs should be of the type {Symbol,AbstractVector}. In these vectors you can either throw a symbol from the following list:","category":"page"},{"location":"","page":"Home","title":"Home","text":":mean : The sample mean of the variable\n:var : The sample variance of the variable\n:trace : The trace of the variable (every value)\n:hist : An histogram of the variable\n:kde : A KDE estimation of the variable\n:histkde : A KDE estimation combined with an histogram\n:autocov : The sample auto-covariance","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can also pass an OnlineStat object from OnlineStats.jl. By default, it will plot the value of the OnlineStat at every iteration as a trace. If you want a specific implementation of a certain stat please open an issue.","category":"page"},{"location":"#Recording-the-sampling","page":"Home","title":"Recording the sampling","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If you want to make a cool animation you can use the built-in recording features of Makie. Here is the simple example, using the Turing example from above:","category":"page"},{"location":"","page":"Home","title":"Home","text":"record(cb.scene, joinpath(@__DIR__, \"video.webm\")) do io\n    addIO!(cb, io)\n    sample(m,  NUTS(0.65), 300; callback = cb)\nend","category":"page"}]
}
