import{_ as e,c as t,o as a,a6 as i}from"./chunks/framework.CrAROFX7.js";const o="/svilupp.github.io/ProToPortal.jl/previews/PR9/assets/screen-capture-plain.CMx6SdfL.gif",b=JSON.parse('{"title":"ProToPortal","description":"","frontmatter":{},"headers":[],"relativePath":"introduction.md","filePath":"introduction.md","lastUpdated":null}'),n={name:"introduction.md"},r=i(`<h1 id="ProToPortal" tabindex="-1">ProToPortal <a class="header-anchor" href="#ProToPortal" aria-label="Permalink to &quot;ProToPortal {#ProToPortal}&quot;">​</a></h1><p>Documentation for <a href="https://github.com/svilupp/ProToPortal.jl" target="_blank" rel="noreferrer">ProToPortal</a>.</p><p>Welcome to <strong>ProToPortal</strong>, your portal to the magic of <a href="https://github.com/svilupp/PromptingTools.jl" target="_blank" rel="noreferrer">PromptingTools.jl</a>! ProToPortal is a personal project designed to enhance productivity, potentially yours too!</p><p>Given it&#39;s a UI-rich application, it will contain many bugs I&#39;m unaware of — let me know!</p><div class="warning custom-block github-alert"><p class="custom-block-title">This application is still in development. Use at your own risk.</p><p></p></div><h2 id="Getting-Started" tabindex="-1">Getting Started <a class="header-anchor" href="#Getting-Started" aria-label="Permalink to &quot;Getting Started {#Getting-Started}&quot;">​</a></h2><p>This guide assumes that you have already set up PromptingTools.jl! At the very least, you need to have <code>OPENAI_API_KEY</code> set in your environment.</p><ol><li><p>Clone the repository</p></li><li><p>Run the following command to install the necessary dependencies:</p></li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Pkg; Pkg</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">activate</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;.&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">); Pkg</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">instantiate</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;.&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><ol><li>Launch the GUI</li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># as a quick hack if you don&#39;t have your environment variables set up, run the below line with your OpenAI key</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># ENV[&quot;OPENAI_API_KEY&quot;] = &quot;&lt;your_openai_api_key&gt;&quot;</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">include</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;main.jl&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Then head to your browser and go to <a href="http://127.0.0.1:8000" target="_blank" rel="noreferrer">http://127.0.0.1:8000</a> to see the app.</p><p>For the purists: simply run <code>julia --project -t auto main.jl</code> in your terminal (once installed)!</p><p>How to start? Type <code>Say hi!</code> in the question box on the Chat tab and click Submit (or press CTRL+ENTER).</p><p><strong>Preview:</strong><img src="`+o+'" alt=""></p><h2 id="Motivation" tabindex="-1">Motivation <a class="header-anchor" href="#Motivation" aria-label="Permalink to &quot;Motivation {#Motivation}&quot;">​</a></h2><p>Imagine you&#39;re walking your dog and suddenly come up with a brilliant idea for a code snippet you need urgently.</p><p>Using ChatGPT on your phone is feasible, but slow and cumbersome—typing out or dictating a precise prompt can be a real hassle, not to mention you can&#39;t close the app or run the code to see if it works.</p><p>Enter <strong>ProToPortal</strong>: Select the JuliaExpertAsk template, use speech-to-text on your phone to dictate your needs, enable auto-fixing with Monte-Carlo Tree Search (<code>airetry!</code>), and watch as your phone processes 6 iterations of the code before ChatGPT generates its first response!</p><p>For a preview, see the video: <code>docs/src/videos/screen-capture-code-fixing.mp4</code></p><h2 id="Key-Highlights" tabindex="-1">Key Highlights <a class="header-anchor" href="#Key-Highlights" aria-label="Permalink to &quot;Key Highlights {#Key-Highlights}&quot;">​</a></h2><ul><li><p><strong>Accessible Anywhere</strong>: Use it on any device—laptop, phone, etc.—with numerous prompt templates designed to save your keystrokes.</p></li><li><p><strong>Code Evaluation and Fixing</strong>: The only GUI that lets you evaluate and fix your Julia code directly, saving you from the hassle of copy-pasting.</p></li><li><p><strong>Automatic Replies</strong>: Automate standard replies to refine responses, either through fixed messages or critic templates mimicking a separate agent.</p></li></ul><h2 id="Features-by-Tab" tabindex="-1">Features by Tab <a class="header-anchor" href="#Features-by-Tab" aria-label="Permalink to &quot;Features by Tab {#Features-by-Tab}&quot;">​</a></h2><h3 id="Login-Page" tabindex="-1">Login Page <a class="header-anchor" href="#Login-Page" aria-label="Permalink to &quot;Login Page {#Login-Page}&quot;">​</a></h3><ul><li><p>Comes with a simple login if you want to deploy it (Fly.io works like a charm!)</p></li><li><p>Ignore the password when deploying locally (enter an empty password).</p></li></ul><h3 id="Chat-Tab" tabindex="-1">Chat Tab <a class="header-anchor" href="#Chat-Tab" aria-label="Permalink to &quot;Chat Tab {#Chat-Tab}&quot;">​</a></h3><ul><li><p><strong>Advanced Settings</strong>:</p><ul><li><p>Rewind conversations by deleting messages you dislike or to restart the conversation.</p></li><li><p>Control creativity with model temperature settings.</p></li><li><p>Enable code evaluation (<code>AICode</code>) and auto-fixing using advanced algorithms like <code>airetry!</code> and Monte-Carlo Tree search.</p></li><li><p>Automate replies with pre-configured templates (~critic agents) or custom messages.</p></li></ul></li><li><p><strong>Templates</strong>:</p><ul><li><p>Begin conversations from a template, opening new input fields interpolated into text variables.</p></li><li><p>Add your templates by placing them in the <code>templates/</code> folder for automatic loading.</p></li></ul></li><li><p><strong>Chat</strong>:</p><ul><li><p>Submit your question by clicking &quot;Submit&quot; or via CTRL+ENTER.</p></li><li><p>Edit any message in the conversation (simply click on it and make a change).</p></li><li><p>Delete unwanted messages with ease (accidental deletions made difficult by hiding the button in the &quot;Advanced Settings&quot;).</p></li><li><p>Copy the text of any message (see top right corner icon).</p></li><li><p>Start &quot;new chat&quot; with conversations automatically saved both on disk and in history.</p></li></ul></li></ul><h3 id="History-Tab" tabindex="-1">History Tab <a class="header-anchor" href="#History-Tab" aria-label="Permalink to &quot;History Tab {#History-Tab}&quot;">​</a></h3><ul><li><p>Browse and load past conversations with a simple click.</p></li><li><p>Fork past conversations for continued exploration without altering the original history.</p></li><li><p>View the current session or reload to fetch all saved conversations.</p></li></ul><h3 id="Templates-Tab" tabindex="-1">Templates Tab <a class="header-anchor" href="#Templates-Tab" aria-label="Permalink to &quot;Templates Tab {#Templates-Tab}&quot;">​</a></h3><ul><li><p>Explore all available templates with previews and metadata to select the most suitable one.</p></li><li><p>Search functionality for quick filtering by partial names or keywords.</p></li></ul><h3 id="Configuration-Tab" tabindex="-1">Configuration Tab <a class="header-anchor" href="#Configuration-Tab" aria-label="Permalink to &quot;Configuration Tab {#Configuration-Tab}&quot;">​</a></h3><ul><li><p>Change the default model or add new ones from PromptingTools.</p></li><li><p>Modify the default system prompt used when not employing a template.</p></li></ul><h3 id="Meta-Prompting-Tab" tabindex="-1">Meta-Prompting Tab <a class="header-anchor" href="#Meta-Prompting-Tab" aria-label="Permalink to &quot;Meta-Prompting Tab {#Meta-Prompting-Tab}&quot;">​</a></h3><ul><li><p>An experimental meta-prompting experience based on <a href="https://arxiv.org/pdf/2401.12954" target="_blank" rel="noreferrer">arxiv</a>.</p></li><li><p>The model calls different &quot;experts&quot; to solve the provided tasks.</p></li></ul><h3 id="Prompt-Builder-Tab" tabindex="-1">Prompt Builder Tab <a class="header-anchor" href="#Prompt-Builder-Tab" aria-label="Permalink to &quot;Prompt Builder Tab {#Prompt-Builder-Tab}&quot;">​</a></h3><ul><li><p>Generate prompt templates (for use in Chat) from a brief description of a task.</p></li><li><p>Generate multiple templates at once to choose from.</p></li><li><p>Iterate all of them by providing more inputs in the text field.</p></li><li><p>Once you&#39;re done, click &quot;Apply in Chat&quot; to jump to the normal chat (use as any other template, eg, fill in variables at the top).</p></li></ul><p>And rich logging in the REPL to see what the GUI is doing under the hood!</p><h2 id="Alternatives" tabindex="-1">Alternatives <a class="header-anchor" href="#Alternatives" aria-label="Permalink to &quot;Alternatives {#Alternatives}&quot;">​</a></h2><p>ProToPortal is a simple personal project and it cannot compete with established LLM GUIs!</p><p>If you&#39;re looking for more robust software, consider the following tools:</p><ul><li><p>Open Webui: <a href="https://github.com/open-webui/open-webui" target="_blank" rel="noreferrer">https://github.com/open-webui/open-webui</a></p></li><li><p>Oobabooga&#39;s text generation webui: <a href="https://github.com/oobabooga/text-generation-webui" target="_blank" rel="noreferrer">https://github.com/oobabooga/text-generation-webui</a></p></li><li><p>Simple server in llama.cpp (for the purists)</p></li></ul><h2 id="Contributing" tabindex="-1">Contributing <a class="header-anchor" href="#Contributing" aria-label="Permalink to &quot;Contributing {#Contributing}&quot;">​</a></h2><p>Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are <strong>greatly appreciated</strong>. Please open an issue first, because this is first and foremost a simple tool to interact with LLMs on-the-go.</p><h2 id="Acknowledgments" tabindex="-1">Acknowledgments <a class="header-anchor" href="#Acknowledgments" aria-label="Permalink to &quot;Acknowledgments {#Acknowledgments}&quot;">​</a></h2><p>This project would not be possible without the amazing <a href="https://github.com/GenieFramework/Stipple.jl" target="_blank" rel="noreferrer">Stipple.jl</a> from the <a href="https://github.com/GenieFramework/Genie.jl" target="_blank" rel="noreferrer">Genie.jl</a> family! It&#39;s just a Stipple.jl wrapper around PromptingTools.jl.</p>',46),s=[r];function l(p,h,u,d,c,g){return a(),t("div",null,s)}const k=e(n,[["render",l]]);export{b as __pageData,k as default};
