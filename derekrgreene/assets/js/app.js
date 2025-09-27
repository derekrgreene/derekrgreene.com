// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Theme toggle functionality
document.addEventListener('DOMContentLoaded', function() {
  const themeToggle = document.getElementById('theme-toggle');
  const themeContainer = document.getElementById('theme-container');
  const sunIcon = document.getElementById('sun-icon');
  const moonIcon = document.getElementById('moon-icon');
  
  // Check for saved theme preference or default to dark
  const currentTheme = localStorage.getItem('theme') || 'dark';
  
  // Apply initial theme
  if (currentTheme === 'light') {
    themeContainer.classList.remove('bg-gray-900', 'text-gray-100');
    themeContainer.classList.add('bg-gray-100', 'text-gray-900');
    sunIcon.classList.add('hidden');
    moonIcon.classList.remove('hidden');
    
    // Update all cards to light theme
    document.querySelectorAll('.border-gray-600').forEach(card => {
      card.classList.remove('border-gray-600', 'bg-gray-800');
      card.classList.add('border-gray-300', 'bg-white');
    });
    
    // Update separators
    document.querySelectorAll('.border-gray-700').forEach(separator => {
      separator.classList.remove('border-gray-700');
      separator.classList.add('border-gray-300');
    });
    
    // Update text colors
    document.querySelectorAll('.text-gray-400').forEach(text => {
      text.classList.remove('text-gray-400');
      text.classList.add('text-gray-600');
    });
    
    // Update project description text to be darker in light mode
    document.querySelectorAll('.project-details p, .project-details li').forEach(text => {
      text.classList.remove('text-gray-300');
      text.classList.add('text-gray-800');
    });
    
    // Update expanded project cards to light theme highlighting
    document.querySelectorAll('.project-card.bg-gray-700').forEach(card => {
      card.classList.remove('bg-gray-700');
      card.classList.add('bg-gray-100');
    });
  }
  
  themeToggle.addEventListener('click', function() {
    if (themeContainer.classList.contains('bg-gray-900')) {
      // Switch to light mode - all changes happen at once
      requestAnimationFrame(() => {
        themeContainer.classList.remove('bg-gray-900', 'text-gray-100');
        themeContainer.classList.add('bg-gray-100', 'text-gray-900');
        sunIcon.classList.add('hidden');
        moonIcon.classList.remove('hidden');
        
        // Update all cards to light theme
        document.querySelectorAll('.border-gray-600').forEach(card => {
          card.classList.remove('border-gray-600', 'bg-gray-800');
          card.classList.add('border-gray-300', 'bg-white');
        });
        
        // Update separators
        document.querySelectorAll('.border-gray-700').forEach(separator => {
          separator.classList.remove('border-gray-700');
          separator.classList.add('border-gray-300');
        });
        
        // Update text colors
        document.querySelectorAll('.text-gray-400').forEach(text => {
          text.classList.remove('text-gray-400');
          text.classList.add('text-gray-600');
        });
        
        // Update project description text to be darker in light mode
        document.querySelectorAll('.project-details p, .project-details li').forEach(text => {
          text.classList.remove('text-gray-300');
          text.classList.add('text-gray-800');
        });
        
        // Update expanded project cards to light theme highlighting
        document.querySelectorAll('.project-card.bg-gray-700').forEach(card => {
          card.classList.remove('bg-gray-700');
          card.classList.add('bg-gray-100');
        });
        
        localStorage.setItem('theme', 'light');
      });
    } else {
      // Switch to dark mode - all changes happen at once
      requestAnimationFrame(() => {
        themeContainer.classList.remove('bg-gray-100', 'text-gray-900');
        themeContainer.classList.add('bg-gray-900', 'text-gray-100');
        sunIcon.classList.remove('hidden');
        moonIcon.classList.add('hidden');
        
        // Update all cards to dark theme
        document.querySelectorAll('.border-gray-300').forEach(card => {
          card.classList.remove('border-gray-300', 'bg-white');
          card.classList.add('border-gray-600', 'bg-gray-800');
        });
        
        // Update separators
        document.querySelectorAll('.border-gray-300').forEach(separator => {
          separator.classList.remove('border-gray-300');
          separator.classList.add('border-gray-700');
        });
        
        // Update text colors
        document.querySelectorAll('.text-gray-600').forEach(text => {
          text.classList.remove('text-gray-600');
          text.classList.add('text-gray-400');
        });
        
        // Restore project description text to original colors in dark mode
        document.querySelectorAll('.project-details p, .project-details li').forEach(text => {
          text.classList.remove('text-gray-800');
          text.classList.add('text-gray-300');
        });
        
        // Update expanded project cards to dark theme highlighting
        document.querySelectorAll('.project-card.bg-gray-100').forEach(card => {
          card.classList.remove('bg-gray-100');
          card.classList.add('bg-gray-700');
        });
        
        localStorage.setItem('theme', 'dark');
      });
    }
  });
  
  // Project card expansion functionality
  const projectCards = document.querySelectorAll('.project-card');
  
  projectCards.forEach(card => {
    card.addEventListener('click', function() {
      const details = this.querySelector('.project-details');
      const isExpanded = !details.classList.contains('hidden');
      
      // Close all other expanded cards first
      projectCards.forEach(otherCard => {
        if (otherCard !== this) {
          const otherDetails = otherCard.querySelector('.project-details');
          otherDetails.classList.add('hidden');
          // Check current theme and apply appropriate colors
          if (themeContainer.classList.contains('bg-gray-900')) {
            // Dark mode
            otherCard.classList.remove('bg-gray-700', 'ring-2', 'ring-emerald-500/20');
            otherCard.classList.add('bg-gray-800');
          } else {
            // Light mode
            otherCard.classList.remove('bg-gray-100', 'ring-2', 'ring-emerald-500/20');
            otherCard.classList.add('bg-white');
          }
        }
      });
      
      // Toggle current card
      if (isExpanded) {
        details.classList.add('hidden');
        // Check current theme and apply appropriate colors
        if (themeContainer.classList.contains('bg-gray-900')) {
          // Dark mode
          this.classList.remove('bg-gray-700', 'ring-2', 'ring-emerald-500/20');
          this.classList.add('bg-gray-800');
        } else {
          // Light mode
          this.classList.remove('bg-gray-100', 'ring-2', 'ring-emerald-500/20');
          this.classList.add('bg-white');
        }
      } else {
        details.classList.remove('hidden');
        // Check current theme and apply appropriate colors
        if (themeContainer.classList.contains('bg-gray-900')) {
          // Dark mode
          this.classList.remove('bg-gray-800');
          this.classList.add('bg-gray-700', 'ring-2', 'ring-emerald-500/20');
        } else {
          // Light mode
          this.classList.remove('bg-white');
          this.classList.add('bg-gray-100', 'ring-2', 'ring-emerald-500/20');
        }
        
        // Load DCV visualization if this is the DCV project
        const projectType = this.dataset.project;
        if (projectType === 'dcv-dependency-map') {
          loadDCVVisualization();
        }
      }
    });
  });
  
  // Function to load DCV visualization
  function loadDCVVisualization() {
    console.log('loadDCVVisualization called');
    const container = document.getElementById('dcv-container');
    console.log('Container found:', container);
    if (!container || container.children.length > 0) {
      console.log('Container not found or already has children, returning');
      return; // Already loaded
    }
    
    // Load D3.js if not already loaded
    if (typeof d3 === 'undefined') {
      console.log('D3.js not loaded, loading from CDN...');
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/d3@7';
      script.onload = () => {
        console.log('D3.js loaded successfully');
        // Wait a bit for D3 to initialize, then load the visualization
        setTimeout(loadDCVCode, 100);
      };
      script.onerror = (error) => {
        console.error('Failed to load D3.js:', error);
      };
      document.head.appendChild(script);
    } else {
      console.log('D3.js already loaded, proceeding...');
      loadDCVCode();
    }
  }
  
  function loadDCVCode() {
    console.log('loadDCVCode called');
    const container = document.getElementById('dcv-container');
    if (!container) {
      console.log('Container not found in loadDCVCode');
      return;
    }
    
    // Create the visualization container
    container.innerHTML = `
      <div id="dcv-svg-container" class="w-full overflow-x-auto"></div>
    `;
    
    console.log('Container HTML set, loading data...');
    // Load the data and create visualization
    loadDCVData();
  }
  
  async function loadDCVData() {
    console.log('loadDCVData called');
    try {
      console.log('Fetching data from /sources/research/DCV-Dependencies/data.json');
      const response = await fetch('/sources/research/DCV-Dependencies/data.json');
      console.log('Response status:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      console.log('Data loaded successfully:', data);
      createDCVVisualization(data);
    } catch (error) {
      console.error('Error loading DCV data:', error);
      document.getElementById('dcv-container').innerHTML = `<p class="text-red-400">Error loading visualization data: ${error.message}</p>`;
    }
  }
  
  function createDCVVisualization(data) {
    const container = document.getElementById('dcv-svg-container');
    if (!container) return;
    
    // Dimensions of the chart.
    const width = 1200;
    const height = 600; 
    const rowSpacing = 100;
    const columnSpacing = 100; 
    const defaultOpacity = 0.5;
    const circleRadius = 10;
    const arrowWidth = 4;
    const arrowHeight = 4;
    const arrowSpacing = circleRadius + 3 * arrowHeight;

    // Specify the color scale.
    const color = d3.scaleOrdinal(d3.schemeCategory10);
    const links = data.links;
    const nodes = data.nodes;
    let totalItemsPerRow = {};

    // Assign x and y coordinates to nodes
    nodes.forEach((d, i) => {
        if (totalItemsPerRow[d.row] === undefined) { totalItemsPerRow[d.row] = 1; } else { totalItemsPerRow[d.row] += 1; }
    });

    let itemsPerRow = {};
    nodes.forEach((d, i) => {
        d.y = d.row * rowSpacing;
        if (itemsPerRow[d.row] === undefined) { itemsPerRow[d.row] = 1; } else { itemsPerRow[d.row] += 1; }
        d.x = itemsPerRow[d.row] * columnSpacing - (totalItemsPerRow[d.row] * columnSpacing / 2);
    });

    let seen_paths = {};
    links.forEach((d, i) => {
        d.source = nodes.find(n => n.id === d.source);
        d.target = nodes.find(n => n.id === d.target);
        
        d.x1 = d.source.x;
        d.y1 = d.source.y;
        d.x2 = d.target.x;
        d.y2 = d.target.y;

        let path = [d.source.id, d.target.id].sort().join("-");
        if (seen_paths[path] === undefined) {
            seen_paths[path] = 1;
        } else {
            seen_paths[path] += 1;
        }

        d.curvature = seen_paths[path] - 1; 
    });

    // Helper functions
    function curvedLine(d) {
        let controlX = d.x2;
        let controlY = d.y1 + (d.y2 - d.y1) / 2;
        let destX = d.x2;
        let destY = d.y2 - arrowSpacing;
        let srcX = d.x1;
        let srcY = d.y1 + circleRadius;

        if (d.y2 < d.y1) {
          destY = d.y2 + arrowSpacing;
          srcY = d.y1 - circleRadius;
        }

        if (d.y1 == d.y2) {
            destY = d.y2;
            destX = d.x2 - Math.abs(d.x2 - d.x1)/(d.x2 - d.x1) * arrowSpacing;
            srcY = d.y1;
            srcX = d.x1 + Math.abs(d.x2 - d.x1)/(d.x2 - d.x1) * circleRadius;
            controlX = destX + (srcX - destX) / 2;
            controlY = srcY; 
        }

        if (d.y1 != d.y2) {
            controlY = controlY - d.curvature * 20;
            controlX = controlX - d.curvature * 10;
        } else {
            controlY = controlY - d.curvature * 10;
        }

        return `M${srcX},${srcY}Q${controlX},${controlY} ${destX},${destY}`;
    }

    function fadeAll() {
        let fadeOpacity = 0.2;
        link.attr("stroke-opacity", fadeOpacity);
        node.attr("opacity", fadeOpacity);
        d3.selectAll("text").attr("opacity", fadeOpacity);
        d3.selectAll("marker[id^='arrow']").attr("opacity", fadeOpacity);
    }
    
    function unfadeAll() {
        link.attr("stroke-opacity", defaultOpacity);
        node.attr("opacity", 1);
        d3.selectAll("text").attr("opacity", 1);
        d3.selectAll("marker[id^='arrow']").attr("opacity", defaultOpacity);
    }
    
    function highlightPath(br_section) {
        d3.selectAll(`[class="${br_section}"]`).attr("stroke", d => color(br_section)).attr("stroke-opacity", 1);
            
        let brLinks = d3.selectAll(`[class="${br_section}"]`).data();
        const uniqueNodeIds = [...new Set(brLinks.map(item => item.source.id).concat(brLinks.map(item => item.target.id)))].map(id => `#${id}`);
        d3.selectAll(uniqueNodeIds.join(", ")).attr("opacity", 1);
        d3.selectAll(uniqueNodeIds.map(id => `#label-${id.substring(1)}`).join(", ")).attr("opacity", 1);
        d3.selectAll(`#arrow${color(br_section).substring(1)}`).attr("opacity", 1);
        d3.selectAll(`text[id='legend-${br_section}']`).attr("opacity", 1);
    }

    // Create the SVG container.
    const svg = d3.create("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", [-width/2, 0, width, height])
        .attr("style", "max-width: 100%; height: auto;");

    const arrows = svg.append("svg:defs");
    for (let c of d3.schemeCategory10) {
        arrows.append("svg:marker")
        .attr("id", `arrow${c.substring(1)}`)
        .attr("viewBox", "0 -5 10 10")
        .attr('refX', 0)
        .attr("markerWidth", arrowWidth)
        .attr("markerHeight", arrowHeight)
        .attr("orient", "auto")
        .attr("fill", c)
        .attr("opacity", defaultOpacity)
        .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5");
    }

    const link = svg.append("g")
        .attr("id", "links")
        .attr("fill", "none")
        .selectAll()
        .data(links)
        .join("path")
        .attr("d", curvedLine)
        .attr("class", d => d.br_section)
        .attr("stroke", d => color(d.br_section))
        .attr("stroke-width", 3)
        .attr("stroke-opacity", defaultOpacity)
        .attr("marker-end", d => `url(#arrow${color(d.br_section).substring(1)})`)
        .on("mouseover", (event, d) => {
            if (clickedSection) {return;}
            fadeAll();
            highlightPath(d.br_section);
        }).on("mouseout", (event, d) => {
            if (clickedSection) {return;}
            unfadeAll();
        });

    const node = svg.append("g")
        .attr("id", "nodes")
        .selectAll("circle")
        .data(nodes)
        .join("circle")
        .attr("id", d => d.id)
        .attr("r", circleRadius)
        .attr("cx", d => d.x)
        .attr("cy", d => d.y)
        .attr("fill", d => color(d.medium));

    node.append("title")
        .text(d => d.display);

    link.append("title")
        .text(d => `BR section: ${d.br_section}`);

    svg.append("g")
        .attr("id", "texts")
        .selectAll("text")
        .data(nodes)
        .join("text")
        .attr("x", d => d.x + circleRadius)
        .attr("y", d => d.y)
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("id", d => `label-${d.id}`)
        .text(d => d.display);

    let clickedSection = false;

    // row labels
    const rowNames = {
        1: "1 - Certificate Request",
        2: "",
        3: "2 - Indirection",
        4: "3 - Validation"
    };

    const rowLabels = svg.append("g")
        .attr("id", "row-labels")
        .selectAll("text")
        .data(Object.keys(totalItemsPerRow).sort((a, b) => a - b)) 
        .join("text")
        .attr("x", -width / 2.5 + 20)
        .attr("y", d => d * rowSpacing)
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("fill", d => color(d))
        .attr("font-size", "14px")
        .text(d => rowNames[d]);

    // row hover and click functionality
    rowLabels
        .on("mouseover", (event, d) => {
            if (!clickedRow) {
                fadeAll();
                highlightRow(d);
            }
        })
        .on("mouseout", (event, d) => {
            if (!clickedRow) { 
                unfadeAll();
            }
        })
        .on("click", (event, d) => {
            if (clickedRow === Number(d)) {
                clickedRow = false;
                unfadeAll();
            } else {
                clickedRow = Number(d);
                fadeAll();
                highlightRow(d);
            }
        });

    function highlightRow(row) {
        const rowNum = Number(row);
        
        node.filter(d => d.row === rowNum)
            .attr("opacity", 1);
        
        svg.selectAll(`text[id^="label-"]`)
            .filter(d => d.row === rowNum)
            .attr("opacity", 1);
        
        rowLabels.filter(d => Number(d) === rowNum)
            .attr("opacity", 1);
    }

    let clickedRow = false;

    // legend with BR sections
    svg.append("g")
        .selectAll("text")
        .data([...new Set(links.map(d => d.br_section))].sort().map(d => ({br_section: d})))
        .join("text")
        .attr("id", d => `legend-${d.br_section}`)
        .attr("x", width/2 - 100)
        .attr("y", (d, i) => i * 20 + 100)
        .attr("text-anchor", "start")
        .attr("dominant-baseline", "middle")
        .attr("fill", d => color(d.br_section))
        .text(d => d.br_section)
        .on("mouseover", (event, d) => {
            if (!clickedSection) {
                fadeAll();
                highlightPath(d.br_section);
            }
        }).on("mouseout", (event, d) => {
            if (!clickedSection) {
                unfadeAll();
            }
        }).on("click", (event, d) => {
            if (clickedSection && d.br_section == clickedSection) {
                clickedSection = false;
                unfadeAll();
            } else if (clickedSection && d.br_section != clickedSection) {
                clickedSection = d.br_section;
                fadeAll();
                highlightPath(d.br_section);
            } else {
                clickedSection = d.br_section;
                fadeAll();
                highlightPath(d.br_section);
            }
        });

    // Add the SVG to the container
    container.innerHTML = '';
    container.appendChild(svg.node());
    
    // Add overflow style for SVG container to prevent text cut off
    const style = document.createElement('style');
    style.textContent = 'svg { overflow: visible; }';
    document.head.appendChild(style);
  }
});
