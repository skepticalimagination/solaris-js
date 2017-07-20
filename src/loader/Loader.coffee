import {DefaultLoadingManager} from 'three'
import publicize from '../helpers/publicizer'

class Loader
  constructor: (@container, @root) ->
    template = document.createElement('template')
    template.innerHTML = '''
      <div class="loader">
        <div class="gauge">
          <div class="fill"></div>
        </div>
      </div>
    '''
    @el = template.content.firstChild
    @container.appendChild(@el)

    @gauge = @el.querySelector('.gauge')
    @fill = @el.querySelector('.gauge .fill')

    @manager = DefaultLoadingManager
    
    @manager.onProgress = (url, itemsLoaded, itemsTotal) =>
      @fill.style.width = "#{itemsLoaded / itemsTotal * 100}%"

    @manager.onError = (url) ->
      console.log "Solaris.js: error loading #{url}"

    @manager.onLoad = =>
      @fill.style.width = '100%'
      @el.style.display = 'none'

export default publicize Loader
