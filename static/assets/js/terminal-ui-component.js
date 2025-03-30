class TerminalUI extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });

    this.shadowRoot.innerHTML = `
      <style>
        .terminal {
          width: 80%;
          max-width: 800px;
          height: 60vh;
          border: 2px solid lime;
          padding: 10px;
          display: flex;
          flex-direction: column;
          overflow: hidden;
          background-color: #F8F8F8;
        }
        .title-bar {
          background-color: lime;
          color: black;
          text-align: center;
          padding: 5px;
          font-weight: bold;
        }
        #console {
          flex-grow: 1;
          overflow-y: auto;
          white-space: pre-wrap;
          word-wrap: break-word;
          padding: 5px;
        }
        .input-line {
          display: flex;
        }
        .prompt {
          flex-shrink: 0;
        }
        input {
          background: none;
          border: none;
          color: lime;
          font-family: 'Comic sans', monospace;
          font-size: 16px;
          outline: none;
          width: 100%;
        }
      </style>
      <div class="terminal">
        <div class="title-bar">admin@localhost</div>
        <div id="console"></div>
        <div class="input-line">
          <span class="prompt" id="prompt">admin@localhost:~$</span>&nbsp;
          <input id="command-input" type="text" autofocus />
        </div>
      </div>
    `;

    this.consoleDiv = this.shadowRoot.getElementById('console');
    this.inputField = this.shadowRoot.getElementById('command-input');
    this.promptSpan = this.shadowRoot.getElementById('prompt');
    this.currentDir = "~"; 
  }

  connectedCallback() {
    this.printToConsole("Type 'help' to see available commands.");

    this.inputField.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter') {
        const command = this.inputField.value;
        this.inputField.value = ''; 

        if (command === "darkmode") {
          this.shadowRoot.querySelector('.terminal').style.backgroundColor = "#333";
          this.shadowRoot.querySelector('.terminal').style.color = "white";
          return;
        }
        if (command === "lightmode") {
          this.shadowRoot.querySelector('.terminal').style.backgroundColor = "#F8F8F8";
          this.shadowRoot.querySelector('.terminal').style.color = "black";
          return;
        }

        if (command === "help") {
          this.printToConsole("darkmode : Enable dark mode for the terminal");
          this.printToConsole("lightmode : Enable light mode for the terminal");
          this.printToConsole("cd : Change directory");
          this.printToConsole("ls : List files in the current directory");
          this.printToConsole("pwd : Show current working directory");
          this.printToConsole("date : Display current date and time");
          this.printToConsole("echo : Output the given text");
          this.printToConsole("cat : Display contents of a file");
          return;
        }

        if (command.includes('/.') || command.startsWith('cat .') || command.startsWith('ls .')) {
          this.printToConsole("Access to hidden files or directories is not allowed!");
          return;
        }

        const response = await fetch('/run_command', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({ command })
        });
        const data = await response.json();
        this.printToConsole(data.output);

        if (command.startsWith("cd ") && data.new_dir) {
          this.currentDir = data.new_dir.replace("/home/derek", "~");
          this.promptSpan.textContent = `admin@localhost:${this.currentDir}$`;
        }
      }
    });
  }

  printToConsole(text) {
    this.consoleDiv.textContent += text + '\n';
    this.consoleDiv.scrollTop = this.consoleDiv.scrollHeight;
  }
}
customElements.define('terminal-ui', TerminalUI);