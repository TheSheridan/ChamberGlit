extends Node2D

var borderUpPosPrev:Vector2
var borderDownPosPrev:Vector2
var logoScale=12

var logoTrauma:Vector2
var logoTrauma_limit=20
var logoPosPrev:Vector2

func _ready():
  RenderingServer.set_default_clear_color(Color.BLACK)

  $bgm.play()

  $bg.position=Vector2(ProjectSettings.get_setting('display/window/size/viewport_width')/2,ProjectSettings.get_setting('display/window/size/viewport_height')/2)
  $bg.scale=Vector2(0,0)

  $logo.position=Vector2(ProjectSettings.get_setting('display/window/size/viewport_width')/2,ProjectSettings.get_setting('display/window/size/viewport_height')); logoPosPrev=$logo.position
  $logo.scale=Vector2(0,20)
  $logo.modulate=Color($logo.modulate,0)

  $subtitle.position=Vector2(-ProjectSettings.get_setting('display/window/size/viewport_width'),(ProjectSettings.get_setting('display/window/size/viewport_height')/2+ProjectSettings.get_setting('display/window/size/viewport_width')/5))
  $subtitle.size=Vector2(ProjectSettings.get_setting('display/window/size/viewport_width'),(ProjectSettings.get_setting('display/window/size/viewport_height')))
  $subtitle.modulate=Color($subtitle.modulate,0)

  $borderUp.texture.set_width(ProjectSettings.get_setting('display/window/size/viewport_width'))
  $borderDown.texture.set_width(ProjectSettings.get_setting('display/window/size/viewport_width'))

  borderUpPosPrev.y-=$borderUp.texture.get_height()
  borderDownPosPrev.y=ProjectSettings.get_setting('display/window/size/viewport_height')
  $borderUp.position.y=borderUpPosPrev.y
  $borderDown.position.y=borderDownPosPrev.y

  $cam.position=Vector2(ProjectSettings.get_setting('display/window/size/viewport_width'),ProjectSettings.get_setting('display/window/size/viewport_height'))/2

  sw=true

  print($bgm.stream.get_length())
  print($bgm.get_playback_position())

var timer:int
var Anim_BgSquash_timer:int
var Anim_BgSquash_finished:bool=false
var Anim_TwFinished:bool
var timer_TwFinished:int
var sw:bool
var tw2:bool
@onready var logoScalePrev=$logo.scale
func _process(delta):
  logoTrauma=Vector2(RandomNumberGenerator.new().randf_range(-logoTrauma_limit,logoTrauma_limit),RandomNumberGenerator.new().randf_range(-logoTrauma_limit,logoTrauma_limit)) #TODO?: Use perlin/simplex noise instead of simple RNG?
  $logo.position=logoPosPrev+logoTrauma
  $logo.scale=logoScalePrev+logoTrauma.normalized()

  # The animation for $bg
  timer+=1;if timer>=5:
    Anim_BgSquash_timer+=1
      
    if Anim_BgSquash_timer==1:
      print_rich('[color=GREEN]1')
      create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($bg,'scale',Vector2(20,ProjectSettings.get_setting('display/window/size/viewport_height')),0.2)
    if Anim_BgSquash_timer==20:
      print_rich('[color=GREEN]2')
      create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($bg,'scale',Vector2(ProjectSettings.get_setting('display/window/size/viewport_width'),ProjectSettings.get_setting('display/window/size/viewport_height')),0.45)

      Anim_BgSquash_finished=true
  
  #$logo
  if Anim_BgSquash_finished==true and sw==true:
    create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($borderUp,'position:y',borderUpPosPrev.y+$borderUp.texture.get_height(),1)
    var a=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($borderDown,'position:y',borderDownPosPrev.y-$borderDown.texture.get_height(),1)

    create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($logo,'position:y',ProjectSettings.get_setting('display/window/size/viewport_height')/2,1)
    create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(self,'logoTrauma_limit',0,3)
    create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).tween_property($logo,'scale',Vector2(logoScale,logoScale),0.5)
    create_tween().tween_property($logo,'modulate',Color($logo.modulate,1),0.4)

    if $subtitle.position.x!=0:create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property($subtitle,'position:x',0,1)
    create_tween().tween_property($subtitle,'modulate',Color($subtitle.modulate,1),0.2)
    
    timer_TwFinished+=1
  if timer_TwFinished==90:
    print(3)
    
    timer_TwFinished=121
    sw=false
    Anim_BgSquash_finished=false
    tw2=true

    create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property($subtitle,'position:x',ProjectSettings.get_setting('display/window/size/viewport_width'),1)
    #create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).tween_property($subtitle,'modulate',Color($subtitle.modulate,0),0.75)

    create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property($logo,'position:y',-ProjectSettings.get_setting('display/window/size/viewport_height'),1)
    create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property($logo,'rotation_degrees',180,1)
    create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property($logo,'modulate',Color($logo.modulate,0),0.75)
    create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property($logo,'scale:y',0,0.75)
    
  if timer_TwFinished>=121:
    timer_TwFinished+=1
  if timer_TwFinished==150:
    print(4)
    var a=create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property($bg,'scale',Vector2(0,0),0.5)
  if timer_TwFinished>160:
    print(5)
    $logo.hide()
    create_tween().tween_property($bgm,'volume_db',-50,2)
    
  #if $bgm.stream.get_length()==$bgm.get_playback_position():
  if timer_TwFinished==210:
    #get_tree().change_scene_to_file('res://internal/scenes/scn_Title0/scn_Title0.tscn')
    get_node("/root/Resources").changeScene('res://internal/scenes/scn_Title0/scn_Title0.tscn')
