(() => {
  const renderMermaid = async () => {
    const codeBlocks = Array.from(
      document.querySelectorAll("pre > code.language-mermaid")
    );

    if (codeBlocks.length === 0) {
      return;
    }

    try {
      const { default: mermaid } = await import(
        "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs"
      );

      const diagramNodes = codeBlocks.map((codeBlock) => {
        const diagram = document.createElement("pre");
        diagram.className = "mermaid";
        diagram.textContent = codeBlock.textContent;

        const pre = codeBlock.closest("pre");
        const highlightedBlock = pre.closest(
          "div.highlighter-rouge, figure.highlight"
        );

        (highlightedBlock || pre).replaceWith(diagram);
        return diagram;
      });

      mermaid.initialize({
        startOnLoad: false,
        securityLevel: "strict",
        theme: "base",
        themeVariables: {
          darkMode: true,
          background: "#000000",
          primaryColor: "#0b0b0b",
          primaryTextColor: "#f4f4f2",
          primaryBorderColor: "#d8d8d6",
          lineColor: "#858585",
          secondaryColor: "#171717",
          tertiaryColor: "#0b0b0b",
          edgeLabelBackground: "#000000",
          fontFamily: '"Pretendard Variable", Pretendard, sans-serif',
        },
        flowchart: {
          useMaxWidth: true,
        },
      });

      await mermaid.run({ nodes: diagramNodes });
    } catch (error) {
      console.error("Failed to render Mermaid diagrams.", error);
    }
  };

  if (document.readyState === "complete") {
    renderMermaid();
  } else {
    window.addEventListener("load", renderMermaid, { once: true });
  }
})();
