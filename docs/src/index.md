```@raw html
---
layout: home

hero:
  name: ProToPortal.jl
  tagline: The Portal to the Magic of PromptingTools and Julia-first LLM Coding.
  description: Enhance your productivity with streamlined code automation and intuitive prompt management for Julia.
  image:
    src: https://img.icons8.com/dusk/128/portal.png
    alt: Portal Icon
  actions:
    - theme: brand
      text: Introduction
      link: /introduction
    - theme: alt
      text: Reference
      link: /reference
    - theme: alt
      text: View on GitHub
      link: https://github.com/svilupp/ProToPortal.jl

features:
  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/cloud.png" alt="Accessible Anywhere"/>
    title: Accessible Anywhere
    details: 'ProToPortal is fully responsive, making it accessible on any device—laptop, phone, and more. Save keystrokes and time with a wide range of prompt templates suitable for any situation.'

  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/code.png" alt="Code Evaluation and Fixing"/>
    title: Code Evaluation and Fixing
    details: 'Unique among GUIs, ProToPortal allows direct evaluation and fixing of Julia code. Streamline your workflow by avoiding the need for manual code corrections and copy-pasting.'

  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/fax.png" alt="Automatic Replies"/>
    title: Automatic Replies
    details: 'Enhance your efficiency with automated responses. ProToPortal offers fixed messages and critic templates, acting as a separate agent to handle repetitive interactions effortlessly.'

---
```

````@raw html
<p style="margin-bottom:2cm"></p>

<div class="vp-doc" style="width:80%; margin:auto">

<h1> Why ProToPortal.jl? </h1>

Coding and prompt management should be efficient, not a chore. 

ProToPortal.jl was born from a need to make my own coding efforts and general LLM interactions more productive and hassle-free. It's designed to help you manage and automate your workflows more effectively, whether you're on the go or at your desk. 

It's the first Julia-focused GUI (evaluate Julia code, fix it, critique it - or automate it).

<h2> Quick Start Guide </h2>

Clone ProToPortal, instantiate it, enable your desired settings, and streamline your LLM interactions right away:

```julia
using Pkg; Pkg.activate("."); Pkg.instantiate(".")
include("main.jl")
```

Then head to your browser and go to [http://127.0.0.1:8000](http://127.0.0.1:8000) to see the app.

For more information, see the [Getting Started](/introduction#Getting-Started) section. Explore all available features in the [Features by Tab](/introduction#Features-by-Tab) section.

<br>
Ready to transform your coding productivity? Explore ProToPortal.jl now and start working smarter.
<br><br>
It's easy to deploy to Fly.io, so you can use it on the go. Open an issue if you would like me to publish a tutorial.

</div>
````