// range-slider-element@2.1.0 downloaded from https://ga.jspm.io/npm:range-slider-element@2.1.0/dist/range-slider-element.js

const t={value:"valuenow",min:"valuemin",max:"valuemax"};function e(t=""){const e=String(t).split(".")[1];return e?e.length:0}function i(e,i,s){const n=t[i];n&&e.setAttribute(`aria-${n}`,s)}const s=["min","max","step","value","disabled","value-precision"],n={stepUp:["ArrowUp","ArrowRight"],stepDown:["ArrowDown","ArrowLeft"]},h=document.createElement("template");h.innerHTML="\n  <div data-track></div>\n  <div data-track-fill></div>\n  <div data-runnable-track>\n    <div data-thumb></div>\n  </div>\n";class l extends HTMLElement{
/**
   * Registers the custom element with the global or provided custom element registry.
   *
   * @param {string} [tagName='range-slider'] - The tag name to register the element under.
   * @param {CustomElementRegistry} [registry=window.customElements] - Optional custom element registry.
   * @returns {typeof RangeSliderElement | undefined} - Returns the class constructor if successfully defined, otherwise undefined.
   * @example
   * RangeSliderElement.define();
   * RangeSliderElement.define('my-slider', customElements);
   */
static define(t="range-slider",e=customElements){if(!e.get(t))return e.define(t,l),l}static observedAttributes=s;static formAssociated=!0;#t;#e;#i=[];#s=[];#n=0;constructor(){super(),this.#t=this.attachInternals(),this.addEventListener("focusin",this.#h),this.addEventListener("pointerdown",this.#r),this.addEventListener("keydown",this.#a)}get min(){return this.hasAttribute("min")?Number(this.getAttribute("min")):0}get max(){return this.hasAttribute("max")?Number(this.getAttribute("max")):100}get step(){return this.hasAttribute("step")?Number(this.getAttribute("step")):1}get value(){return this.#i.join(",")}get disabled(){return this.getAttribute("disabled")===""||!1}get valuePrecision(){return this.getAttribute("value-precision")||""}get#o(){return this.getAttribute("orientation")==="vertical"}get#u(){return!!(this.#o||this.getAttribute("dir")==="rtl")}get#l(){return this.#d.length>1}get#d(){return this.querySelectorAll("[data-runnable-track] [data-thumb]")}get#m(){return this.querySelector("[data-track-fill]")}get#c(){return this.#o?this.offsetHeight:this.offsetWidth}set min(t){this.setAttribute("min",t);for(const e of this.#d)i(e,"min",t)}set max(t){this.setAttribute("max",t);for(const e of this.#d)i(e,"max",t)}set step(t){this.setAttribute("step",t)}set value(t){String(t).split(",").map(((t,e)=>{this.#b(e,t)}))}set disabled(t){if(t){this.setAttribute("disabled",""),this.removeAttribute("tabindex");for(const t of this.#d)t.removeAttribute("tabindex")}else{this.removeAttribute("disabled"),this.setAttribute("tabindex","-1");for(const t of this.#d)t.setAttribute("tabindex",0)}}set valuePrecision(t){this.setAttribute("value-precision",t)}get form(){return this.#t.form}get name(){return this.getAttribute("name")}get type(){return this.localName}get validity(){return this.#t.validity}get validationMessage(){return this.#t.validationMessage}get willValidate(){return this.#t.willValidate}checkValidity(){return this.#t.checkValidity()}reportValidity(){return this.#t.reportValidity()}connectedCallback(){this.firstChild||this.appendChild(h.content.cloneNode(!0)),this.disabled||this.setAttribute("tabindex","-1"),this.#d.forEach(((t,e)=>{t.dataset.thumb=e,t.setAttribute("role","slider"),i(t,"min",this.min),i(t,"max",this.max),this.disabled||t.setAttribute("tabindex",0)})),this.value=this.getAttribute("value")||this.#v()}disconnectedCallback(){this.removeEventListener("focusin",this.#h),this.removeEventListener("pointerdown",this.#r),this.removeEventListener("keydown",this.#a)}attributeChangedCallback(t,e,i){e!==i&&(this.value=t==="value"?i:this.value)}#h=t=>{t.target.dataset.thumb!==void 0&&(this.#n=Number(t.target.dataset.thumb))};#r=t=>{if(!this.disabled)if(this.setPointerCapture(t.pointerId),this.addEventListener("pointermove",this.#p),window.addEventListener("pointerup",this.#f),window.addEventListener("pointercancel",this.#f),this.#e=this.value,t.target.dataset.thumb!==void 0)this.#n=Number(t.target.dataset.thumb);else{const{offsetX:e,offsetY:i}=t;this.#n=this.#g(this.#o?i:e),this.#A(this.#o?i:e)}};#p=t=>{t.target===this&&(t.preventDefault(),this.#A(this.#o?t.offsetY:t.offsetX))};#f=t=>{this.releasePointerCapture(t.pointerId),this.removeEventListener("pointermove",this.#p),window.removeEventListener("pointerup",this.#f),window.removeEventListener("pointercancel",this.#f),this.#e!==this.value&&this.dispatchEvent(new Event("change",{bubbles:!0}))};#a=t=>{const e=Object.keys(n).find((e=>n[e].includes(t.code)&&e));document.activeElement!==this.#d[this.#n]&&this.#d[this.#n].focus({focusVisible:!1}),e&&(t.preventDefault(),this[e]())};
/**
   *
   * @param {number} offset
   */
#A=t=>{const e=Math.min(Math.max(t,0),this.#c)/this.#c,i=this.#x(this.#u?1-e:e);this.#b(this.#n,i,["input"])};#v(){return this.max<this.min?this.min:this.min+(this.max-this.min)/2}
/**
   *
   * @param {number} value
   * @returns
   */#w(t){return 100*(t-this.min)/(this.max-this.min)}
/**
   * Fit the percentage complete between the range [min,max]
   * by remapping from [0, 1] to [min, min+(max-min)].
   *
   * @param {number} percent
   * @returns
   */#x(t){return this.min+t*(this.max-this.min)}
/**
   *
   * @param {number} offset
   * @returns
   */#g(t){let e;const i=Math.min(Math.max(t,0),this.#c)/this.#c,s=this.#x(this.#u?1-i:i),n=this.#i.findIndex((t=>s-t<0));if(n===0)e=n;else if(n===-1)e=this.#i.length-1;else{const t=this.#i[n-1],i=this.#i[n];e=Math.abs(t-s)<Math.abs(i-s)?n-1:n}return e}
/**
   *
   * @param {number} index
   * @param {number} value
   * @param {string[]} dispatchEvents
   */#b(t,i,s=[]){const n=this.#i[t],h=Number(this.valuePrecision)||e(this.step)||0,r=this.#i[t-1]||this.min,a=this.#i[t+1]||this.max,o=Math.min(Math.max(i,r),a),u=Math.round(o/this.step)*this.step,d=Number(h?u.toFixed(h):Math.round(u));n!==d&&(this.#i[t]=d,this.#s[t]=this.#w(d),this.#t.setFormValue(this.#i.join(",")),this.#E(t,d),this.#y(),s.map((t=>{this.dispatchEvent(new Event(t,{bubbles:!0}))}))
/**
   *
   * @param {number} index
   * @param {number} value
   */)}#E(t,e){this.#d[t]&&(this.#d[t].style.setProperty(`inset-${this.#o?"block":"inline"}-${this.#o?"end":"start"}`,`${this.#w(e)}%`),i(this.#d[t],"value",e))}#y(){if(!this.#m)return;const t=this.#l?`${this.#s[0]}%`:0,e=`clamp(var(--thumb-size) / 2, ${this.#l?100-this.#s[this.#s.length-1]+"%":100-this.#s[0]+"%"}, 100% - var(--thumb-size) / 2)`;this.#m.style.setProperty("inset-"+(this.#o?"block":"inline"),this.#o?`${e} ${t}`:`${t} ${e}`)}
/**
   * Increments the value
   * @param {number} amount - The amount to increment by.
   */stepUp(t=this.step){const e=this.#i[this.#n]+t;this.#b(this.#n,e,["change"])}
/**
   * Decrements the value
   * @param {number} amount - The amount to decrement by.
   */stepDown(t=this.step){const e=this.#i[this.#n]-t;this.#b(this.#n,e,["change"])}}new URL(import.meta.url).searchParams.has("define","false")||(window.RangeSliderElement=l.define());export{l as default};

