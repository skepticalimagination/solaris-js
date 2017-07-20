import publicize from '../helpers/publicizer'

colorToString = (num) ->
  '#' + ('00000' + (num | 0).toString(16)).substr(-6)

class Label
  constructor: (@model, color, @container) ->
    template = document.createElement('template')
    template.innerHTML = """
      <div class="label">
        <div class="spot"></div>
        #{@model.name}
      </div>
    """
    @el = template.content.firstChild
    @container.appendChild(@el)

    @el.querySelector('.spot').style.borderColor = colorToString(color)

    @el.style.zIndex = 60 if @model.type is 'planet'
    
    @el.addEventListener 'mousewheel', @onWheel, false

  onWheel: (e) =>
    @el.style.display = 'none'

  # @public
  onClick: (cb) ->
    @el.addEventListener 'click', cb

  # @public
  setPosition: (pos) ->
    if not pos
      @el.style.display = 'none' unless @el.style.display is 'none'
    else
      @el.style.transform = "translate3d(#{pos.x}px, #{pos.y}px, 0)"
      @el.style.display = 'block' unless @el.style.display is 'block'

    if @model.type in ['moon', 'spacecraft']
      if not pos or pos.z > 0.9999
        @el.style.display = 'none'
      else
        @el.style.display = 'block'

export default publicize Label, methods: ['onClick', 'setPosition']
