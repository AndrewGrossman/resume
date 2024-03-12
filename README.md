# resume

This is my resume in json-resume format.

To build:

Install resume-cli from node.

```npm install resume-cli```

Install updated theme

```npm install https://github.com/AndrewGrossman/jsonresume-theme-relaxed```

Generate HTML:

```node_modules/resume-cli/build/main.js export "Andrew Grossman - Resume.html" --theme jsonresume-theme-relaxed```

Generate PDF:

```node_modules/resume-cli/build/main.js export "Andrew Grossman - Resume.pdf" --theme jsonresume-theme-relaxed```

