class TerminalUI extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });

    this.shadowRoot.innerHTML = `
      <style>
        .terminal {
          width: 100%; 
          height: 100%;
          border: 2px solid white;
          padding: 10px;
          display: flex;
          flex-direction: column;
          overflow: hidden;
          background-color: #149ddd;
          font-family: 'Comic Sans', monospace;
        }
        .title-bar {
          background-color: white;
          color: black;
          text-align: center;
          padding: 5px;
          font-weight: bold;
          font-family: 'Comic Sans', monospace;
        }
        #console {
          flex-grow: 1;
          overflow-y: auto;
          white-space: pre-wrap;
          word-wrap: break-word;
          padding: 5px;
          color: white;
          font-family: 'Comic Sans', monospace;
        }
        .input-line {
          display: flex;
        }
        .prompt {
          flex-shrink: 0;
          color: white;
        }
        input {
          background: none;
          border: none;
          color: white;
          font-size: 16px;
          outline: none;
          width: 100%;
          font-family: 'Comic Sans', monospace;
        }
      </style>
      <div class="terminal">
        <div class="title-bar">UI Terminal</div>
        <div id="console"></div>
        <div class="input-line">
          <span class="prompt" id="prompt">guest@localhost:~$</span>&nbsp;
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
    
    // Check the saved theme on page load
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      this.setWebsiteTheme(savedTheme);
    }

    this.inputField.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter') {
        const command = this.inputField.value.trim();
        this.inputField.value = '';
        this.handleCommand(command);
      }
    });

    const resizeObserver = new ResizeObserver(() => {
      this.updateTerminalSize();
    });
    resizeObserver.observe(this);
  }

  updateTerminalSize() {
    const terminal = this.shadowRoot.querySelector('.terminal');
    const parent = this.parentElement;
    const parentHeight = parent.offsetHeight;
    const inputLineHeight = this.shadowRoot.querySelector('.input-line').offsetHeight;
    const availableHeight = parentHeight - inputLineHeight;

    terminal.style.height = `${availableHeight}px`;
    terminal.style.width = `${parent.offsetWidth}px`;
  }

  handleCommand(command) {
    if (!command) return;

    const [cmd, ...args] = command.split(' ');
    const argString = args.join(' ');

    switch (cmd.toLowerCase()) {
      case 'help':
        this.showHelp();
        break;
      case 'clear':
        this.clearConsole();
        break;
      case 'dark':
        this.setWebsiteTheme('dark');
        break;
      case 'light':
        this.setWebsiteTheme('light');
        break;
      case 'date':
        this.printToConsole(`Current date: ${new Date().toLocaleDateString()}`);
        break;
      case 'time':
        this.printToConsole(`Current time: ${new Date().toLocaleTimeString()}`);
        break;
      case 'echo':
        this.printToConsole(argString);
        break;
      case 'retro':
        this.enableRetroMode();
        break;
      case 'reset':
        this.resetTerminal();
        break;
      default:
        this.printToConsole(`Unknown command: ${cmd}. Type 'help' for a list of commands.`);
    }
  }

  showHelp() {
    this.printToConsole("Available commands:");
    this.printToConsole("  help          - Show this message");
    this.printToConsole("  clear         - Clear shell");
    this.printToConsole("  dark          - Switch website UI");
    this.printToConsole("  light         - Switch website UI");
    this.printToConsole("  date          - Current date");
    this.printToConsole("  time          - Current time");
    this.printToConsole("  echo          - Print text");
    this.printToConsole("  retro         - Retro style shell");
    this.printToConsole("  reset         - Reset shell style");
  }

  clearConsole() {
    this.consoleDiv.textContent = '';
  }

  setWebsiteTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.setAttribute('data-theme', 'dark');
      this.printToConsole("Website theme changed to dark mode.");
      localStorage.setItem('theme', 'dark');  // Store the selected theme
    } else if (theme === 'light') {
      document.documentElement.setAttribute('data-theme', 'light');
      this.printToConsole("Website theme changed to light mode.");
      localStorage.setItem('theme', 'light');  // Store the selected theme
    } else {
      this.printToConsole("Invalid theme. Use 'dark' or 'light'.");
    }
  }

  resetTerminal() {
    this.shadowRoot.querySelector('.terminal').style.backgroundColor = '#149ddd';
    this.shadowRoot.querySelector('.terminal').style.color = 'white';
    this.shadowRoot.querySelector('#console').style.color = 'white';
    this.shadowRoot.querySelector('.prompt').style.color = 'white';
    this.shadowRoot.querySelector('.title-bar').style.color = '#001B5E';
    this.shadowRoot.querySelector('.title-bar').style.backgroundColor = 'white';
    this.shadowRoot.querySelector('input').style.color = 'white';
    this.shadowRoot.querySelector('.terminal').style.border = '2px solid white;';
    this.shadowRoot.querySelector('.terminal').style.fontFamily = 'Comic Sans, monospace';
    this.shadowRoot.querySelector('.title-bar').style.fontFamily = 'Comic Sans, monospace';
    this.shadowRoot.querySelector('input').style.fontFamily = 'Comic Sans, monospace';
    this.shadowRoot.querySelector('#console').style.fontFamily = 'Comic Sans, monospace';
    this.printToConsole("Terminal reset to default theme.");
  }

  enableRetroMode() {
    this.shadowRoot.querySelector('.terminal').style.backgroundColor = 'black';
    this.shadowRoot.querySelector('.terminal').style.color = 'lime';
    this.shadowRoot.querySelector('#console').style.color = 'lime';
    this.shadowRoot.querySelector('.terminal').style.fontFamily = "'Comic Sans', monospace";
    this.shadowRoot.querySelector('.prompt').style.color = 'lime';
    this.shadowRoot.querySelector('.title-bar').style.color = '#2C003E';
    this.shadowRoot.querySelector('.title-bar').style.backgroundColor = 'lime';
    this.shadowRoot.querySelector('input').style.color = 'lime';
    this.shadowRoot.querySelector('.terminal').style.border = '2px solid lime;';
    this.shadowRoot.querySelector('.terminal').style.fontFamily = 'Courier, monospace';
    this.shadowRoot.querySelector('.title-bar').style.fontFamily = 'Courier, monospace';
    this.shadowRoot.querySelector('input').style.fontFamily = 'Courier, monospace';
    this.shadowRoot.querySelector('#console').style.fontFamily = 'Courier, monospace';
    this.printToConsole("Retro mode enabled!");
  }

  printToConsole(text) {
    this.consoleDiv.textContent += text + '\n';
    this.consoleDiv.scrollTop = this.consoleDiv.scrollHeight;
  }
}

customElements.define('terminal-ui', TerminalUI);
