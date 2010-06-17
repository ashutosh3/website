$ ->
  $('a.resend').click ->
    a: $ this
    a.hide().after '<span>Resending&hellip;</span>'
    $.get @href, ->
      a.next('span').html('Sent!').fadeOut 'slow', ->
        a.next('span').remove()
        a.fadeIn()
    false

  $('a.delete').click ->
    confirm 'Are you sure?'

  $('a.reveal').click ->
    $(this).hide().next('.hidden').slideDown ->
      $(this).find('input').select()
    false

  $(':text:first').focus()

  $('input.url').click ->
    this.select() if @value is @defaultValue

  $('form.reset_password').submit ->
    form: $ this
    email: form.find('input[type=email]').val()
    $.ajax {
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize()
      success: (data) ->
        form.replaceWith """
          <h2>$email has been sent a new password</h2>
          <p>It should arrive shortly.</p>"""
      error: (xhr) ->
        $('#errors').append "<li>$xhr.responseText</li>"
    }
    false

  $('form').submit (evt) ->
    form: $(this).closest('form')
    errors: $('#errors').html('')
    form.find('input').removeClass 'error'

    hasError: false
    highlightError: (selector, message, fn) ->
      invalid: form.find(selector).filter fn
      if invalid.length
        errors.append "<li>$message</li>"
        invalid.addClass 'error'
        hasError: true

    highlightError 'input[type=email]', 'Invalid email address',->
      val: $(this).val()
      val and not /^[a-zA-Z0-9+._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test val

    highlightError 'input[name=name]', 'Name is required', -> !$(this).val()
    highlightError 'input[type=email]:first', 'Email is required', -> !$(this).val()
    highlightError 'input[type=password]:visible', 'Password required', -> !$(this).val()
    highlightError 'input.url', 'Invalid link', ->
      val: $(this).val()
      val and val isnt @defaultValue and not /^https?:\/\/.*\./.test val

    unless hasError
      $('input.url').each ->
        @value: '' if @value is @defaultValue
    not hasError


  if $('time').length > 0
    [y, m, d, h, i, s]: $('time').attr('datetime').split(/[-:TZ]/)...
    ms: Date.UTC y, m-1, d, h, i, s
    $('<div class="about">')
      .html(prettyDate(new Date(ms)))
      .appendTo('#date')

  $('time').hover ->
    $this: $(this)
    [y, m, d, h, i, s]: $this.attr('datetime').split(/[-:TZ]/)...
    ms: Date.UTC y, m-1, d, h, i, s
    dt: new Date(ms)
    $('<div class="localtime blue">')
      .html("
        ${dt.strftime('%a %b %d, %I%P %Z').replace(/\b0/,'')}
        <div>${prettyDate(dt)}</div>
        ")
      .appendTo($this)
  , ->
    $(this).find('.localtime').remove()
