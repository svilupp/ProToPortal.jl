import{_ as e,c as r,o,a6 as a}from"./chunks/framework.Bxt3JIFZ.js";const T=JSON.parse('{"title":"Reference for ProToPortal.jl","description":"","frontmatter":{},"headers":[],"relativePath":"reference.md","filePath":"reference.md","lastUpdated":null}'),t={name:"reference.md"},l=a('<h1 id="Reference-for-ProToPortal.jl" tabindex="-1">Reference for ProToPortal.jl <a class="header-anchor" href="#Reference-for-ProToPortal.jl" aria-label="Permalink to &quot;Reference for ProToPortal.jl {#Reference-for-ProToPortal.jl}&quot;">​</a></h1><ul><li><a href="#ProToPortal.autofix_code-Tuple{PromptingTools.Experimental.AgentTools.AICall}"><code>ProToPortal.autofix_code</code></a></li><li><a href="#ProToPortal.build_lazy_aicall-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}"><code>ProToPortal.build_lazy_aicall</code></a></li><li><a href="#ProToPortal.conversation2transcript-Tuple{Any}"><code>ProToPortal.conversation2transcript</code></a></li><li><a href="#ProToPortal.evaluate_code-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}"><code>ProToPortal.evaluate_code</code></a></li><li><a href="#ProToPortal.label_conversation-Tuple{Any}"><code>ProToPortal.label_conversation</code></a></li><li><a href="#ProToPortal.load_conversations_from_dir-Tuple{String}"><code>ProToPortal.load_conversations_from_dir</code></a></li><li><a href="#ProToPortal.parse_builder-Tuple{PromptingTools.AIMessage}"><code>ProToPortal.parse_builder</code></a></li><li><a href="#ProToPortal.parse_critic-Tuple{PromptingTools.AIMessage}"><code>ProToPortal.parse_critic</code></a></li><li><a href="#ProToPortal.prepare_conversation"><code>ProToPortal.prepare_conversation</code></a></li><li><a href="#ProToPortal.render_messages"><code>ProToPortal.render_messages</code></a></li><li><a href="#ProToPortal.render_template_messages-Tuple{String}"><code>ProToPortal.render_template_messages</code></a></li><li><a href="#ProToPortal.send_to_model-Tuple{Symbol, AbstractVector{&lt;:PromptingTools.AbstractMessage}}"><code>ProToPortal.send_to_model</code></a></li><li><a href="#ProToPortal.send_to_model-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}"><code>ProToPortal.send_to_model</code></a></li><li><a href="#ProToPortal.send_to_model-Tuple{Symbol}"><code>ProToPortal.send_to_model</code></a></li><li><a href="#ProToPortal.template_variables-Tuple{String}"><code>ProToPortal.template_variables</code></a></li><li><a href="#ProToPortal.update_message-Union{Tuple{T}, Tuple{T, AbstractString}} where T&lt;:PromptingTools.AbstractMessage"><code>ProToPortal.update_message</code></a></li><li><a href="#ProToPortal.update_message!-Tuple{Dict{Symbol, Any}}"><code>ProToPortal.update_message!</code></a></li></ul><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.autofix_code-Tuple{PromptingTools.Experimental.AgentTools.AICall}" href="#ProToPortal.autofix_code-Tuple{PromptingTools.Experimental.AgentTools.AICall}">#</a> <b><u>ProToPortal.autofix_code</u></b> — <i>Method</i>. <p>Runs one iteration of <code>airetry!</code></p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L73" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.build_lazy_aicall-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}" href="#ProToPortal.build_lazy_aicall-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}">#</a> <b><u>ProToPortal.build_lazy_aicall</u></b> — <i>Method</i>. <p>Constructs AIGenerate call that mimics if it was just executed</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L61" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.evaluate_code-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}" href="#ProToPortal.evaluate_code-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}">#</a> <b><u>ProToPortal.evaluate_code</u></b> — <i>Method</i>. <p>Code evaluator. Returns the evaluted code block (AICode) and the feedback string.</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L30" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.label_conversation-Tuple{Any}" href="#ProToPortal.label_conversation-Tuple{Any}">#</a> <b><u>ProToPortal.label_conversation</u></b> — <i>Method</i>. <p>Labels the conversation based on the transcript</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L112" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.prepare_conversation" href="#ProToPortal.prepare_conversation">#</a> <b><u>ProToPortal.prepare_conversation</u></b> — <i>Function</i>. <p>Prepares the conversation for sending to the LLM</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L1" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.send_to_model-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}" href="#ProToPortal.send_to_model-Tuple{AbstractVector{&lt;:PromptingTools.AbstractMessage}}">#</a> <b><u>ProToPortal.send_to_model</u></b> — <i>Method</i>. <p>Sends the conversation to the LLM.</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L87" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.send_to_model-Tuple{Symbol, AbstractVector{&lt;:PromptingTools.AbstractMessage}}" href="#ProToPortal.send_to_model-Tuple{Symbol, AbstractVector{&lt;:PromptingTools.AbstractMessage}}">#</a> <b><u>ProToPortal.send_to_model</u></b> — <i>Method</i>. <p>Sends the conversation to the Auto-Critic Template for evaluation and suggestions</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L102" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.send_to_model-Tuple{Symbol}" href="#ProToPortal.send_to_model-Tuple{Symbol}">#</a> <b><u>ProToPortal.send_to_model</u></b> — <i>Method</i>. <p>Sends the conversation to the LLM.</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/llm.jl#L94" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.conversation2transcript-Tuple{Any}" href="#ProToPortal.conversation2transcript-Tuple{Any}">#</a> <b><u>ProToPortal.conversation2transcript</u></b> — <i>Method</i>. <p>Flattens the full conversation for critic to use</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L5" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.load_conversations_from_dir-Tuple{String}" href="#ProToPortal.load_conversations_from_dir-Tuple{String}">#</a> <b><u>ProToPortal.load_conversations_from_dir</u></b> — <i>Method</i>. <p>Loads all conversations from a directory (or its sub-directories)</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L127" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.parse_builder-Tuple{PromptingTools.AIMessage}" href="#ProToPortal.parse_builder-Tuple{PromptingTools.AIMessage}">#</a> <b><u>ProToPortal.parse_builder</u></b> — <i>Method</i>. <p>Parses prompt builder&#39;s response to get the instructions and inputs</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L29" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.parse_critic-Tuple{PromptingTools.AIMessage}" href="#ProToPortal.parse_critic-Tuple{PromptingTools.AIMessage}">#</a> <b><u>ProToPortal.parse_critic</u></b> — <i>Method</i>. <p>Parses critic&#39;s response to get the suggestions and whether they requested to stop</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L11" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.render_messages" href="#ProToPortal.render_messages">#</a> <b><u>ProToPortal.render_messages</u></b> — <i>Function</i>. <p>Returns rendered messages, check if messages need updating as we might have changed the <code>display</code></p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L107" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.render_template_messages-Tuple{String}" href="#ProToPortal.render_template_messages-Tuple{String}">#</a> <b><u>ProToPortal.render_template_messages</u></b> — <i>Method</i>. <p>Renders template displayed messages</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L78" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.template_variables-Tuple{String}" href="#ProToPortal.template_variables-Tuple{String}">#</a> <b><u>ProToPortal.template_variables</u></b> — <i>Method</i>. <p>Extracts the variables from the template name (if found)</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L64" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.update_message!-Tuple{Dict{Symbol, Any}}" href="#ProToPortal.update_message!-Tuple{Dict{Symbol, Any}}">#</a> <b><u>ProToPortal.update_message!</u></b> — <i>Method</i>. <p>Updates the message in the display, if needed</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L91" target="_blank" rel="noreferrer">source</a></p></div><br><div style="border-width:1px;border-style:solid;border-color:black;padding:1em;border-radius:25px;"><a id="ProToPortal.update_message-Union{Tuple{T}, Tuple{T, AbstractString}} where T&lt;:PromptingTools.AbstractMessage" href="#ProToPortal.update_message-Union{Tuple{T}, Tuple{T, AbstractString}} where T&lt;:PromptingTools.AbstractMessage">#</a> <b><u>ProToPortal.update_message</u></b> — <i>Method</i>. <p>Updates the provided message with the new content (creates a new object)</p><p><a href="https://github.com/svilupp/ProToPortal.jl/blob/7a1e2d068be79c16e635daa2bd4d6ae217224301/src/utils.jl#L86" target="_blank" rel="noreferrer">source</a></p></div><br>',36),d=[l];function s(i,p,b,c,n,P){return o(),r("div",null,d)}const h=e(t,[["render",s]]);export{T as __pageData,h as default};
