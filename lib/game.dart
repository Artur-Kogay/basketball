import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Game game = Game();
FpsTextComponent fps = FpsTextComponent();


class MainGame extends StatelessWidget {
  const MainGame({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      overlayBuilderMap: const {
        "PauseMenu": _pauseMenuBuilder,
      },
    );
  }
}



Widget _pauseMenuBuilder(BuildContext buildContext, Game game) {
  return Center(
    child: Stack(
      children: [
        Container(color: Colors.black.withOpacity(.75)),
        Center(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset("assets/images/Banner1.png"),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 25, 0, 0),
                  child: Text("score", style:
                  TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    decoration: TextDecoration.none,
                  ),),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 75, 0, 0),
                  child: Text(score.toString(), style:
                  TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    decoration: TextDecoration.none,
                  ),),
                ),


                Container(
                  margin: EdgeInsets.fromLTRB(25, 145, 0, 0),
                  child: Text("max score", style:
                  TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    decoration: TextDecoration.none,
                  ),),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 175, 0, 0),
                  child: Text(maxScore.toString(), style:
                  TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    decoration: TextDecoration.none,
                  ),),
                ),


              ],
            ),
        )
        ),

        Positioned(

            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: ()=>{game.Restart()},
                      child: Text(
                        "Restart",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      )
                  ),
                ),
              ),
            )
        )
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Container(
        //       margin: EdgeInsets.fromLTRB(35, 0, 0, 175),
        //       child: Text("score", style:
        //       TextStyle(
        //         color: Colors.white,
        //         fontSize: 40,
        //         decoration: TextDecoration.none,
        //       ),),
        //     )
        //   ],
        // )
      ],
    ),
  );
}

Widget overlayBuilder() {
  return GameWidget<Game>(
    game: Game()..paused = true,
    overlayBuilderMap: const {
      'PauseMenu': _pauseMenuBuilder,
    },
    initialActiveOverlays: const ['PauseMenu'],
  );
}

Ball ball = Ball();

Vector2 gravity = Vector2(0, 50);
double pushForce = 250;
int score = 0;
int maxScore = 0;

TextComponent textComponent = TextComponent(
    text: "Score: " + score.toString(),
    anchor: Anchor.center,
    position: Vector2(game.canvasSize.x / 2, 50),
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 35,
      ),
    ));

class Game extends Forge2DGame with DragCallbacks, TapCallbacks {

  Trajectory trajectory = Trajectory();

  Vector2 startPoint = Vector2.zero();
  Vector2 endPoint = Vector2.zero();
  Vector2 direction = Vector2.zero();
  Vector2 force = Vector2.zero();
  double distance = 0;

  int lastHole = 2;
  List<Hole> holes = [];

  bool canPush = true;
  bool firstTouch = false;

  SharedPreferences? preferences;

  Vector2 ballStartPos = Vector2(-8,20);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    SpriteComponent bg = SpriteComponent();
    bg
      ..sprite = await loadSprite("background.jpg")
      ..size = canvasSize;

    add(bg);

    preferences = await SharedPreferences.getInstance();
    if(preferences?.getInt("MaxScore") == null){
      preferences?.setInt("MaxScore", 0);
    }
    maxScore = preferences!.getInt("MaxScore")!;

    world.physicsWorld.setGravity(gravity);
    camera.viewport.add(fps);

    List<TrajectoryDot> dots = [];

    Vector2 pos = Vector2(0, 0);

    for(int i = 0; i < 10; i++)
    {
      TrajectoryDot t = TrajectoryDot(pos);

      world.add(t);
      pos.y -= 5;
      dots.add(t);
    }

    trajectory.prepareDots(dots);

    world.add(ball);

    for(int i = 0; i < 3; i++)
    {
      Hole hole = Hole(Vector2.zero(), Vector2.all(-9999), -9999);
      world.add(hole);
      holes.add(hole);
    }


    world.addAll(createBoundaries());


    add(textComponent);
  }

  void Lose() {
    overlays.add('PauseMenu');
    pauseEngine();
  }

  void placeHoles(){
    holes[0].setPosition(Vector2(12, 14), -30);
    holes[1].setPosition(Vector2(-12, -15), 25);
    holes[2].setPosition(Vector2(12, -40), -25);

    lastHole = 0;
  }

  void addHole(){
    Hole maxHole = getUppest();

    Vector2 pos = Vector2(-maxHole.body.position.x, maxHole.body.position.y - 30);
    double ang = -degrees(maxHole.body.angle);

    Hole hole = Hole(Vector2.zero(), pos, ang);
    world.add(hole);
    holes.add(hole);

    debugPrint(pos.toString() + " " + ang.toString());

    game.camera.moveTo(Vector2(0, ball.body.position.y - 25), speed: 15);
  }

  void Restart(){
    overlays.remove('PauseMenu');
    resumeEngine();

    score = 0;
    canPush = true;
    firstTouch = false;
    textComponent.text = "Score: " + score.toString();

    holes.forEach((element) {
      element.holeTrigger.canEndContact = true;
      element.holeTrigger.canContact = true;
    });

    ball.setActiveBody(false);
    ball.body.setTransform(ballStartPos, 0);

    game.camera.moveTo(Vector2(0, 0));
  }

  Hole getUppest(){
    double max = 0;
    Hole maxHole = Hole(Vector2.zero(), Vector2.all(-9999), -9999);
    holes.forEach((element) {
      if(element.body.position.y < max)
      {
        max = element.body.position.y;
        maxHole = element;
      }
    });

    return maxHole;
  }

  void resetLast(){
    // holes[lastHole].setPosition(Vector2(-holes[lastHole].body.position.x, ball.body.position.y - 20), -holes[lastHole].body.angle);
    // lastHole ++;
    // if(lastHole > 2)
    // {
    //   lastHole = 0;
    // }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }

  @override
  void onMount() {
    super.onMount();

    initVals();
  }

  void initVals(){

    startPoint = Vector2(0, 0);

    endPoint = Vector2(0, -5);
    distance = vectorDistance(startPoint, endPoint) / 2;
    direction = ((startPoint - endPoint) / 2).normalized();
    force = ((direction * distance) * pushForce);

  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    if(firstTouch){
      if(!canPush)
      {
        return;
      }
    }

    startPoint = event.canvasPosition;
    ball.setActiveBody(false);

    trajectory.setVisibility(true);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if(firstTouch){
      if(!canPush)
      {
        return;
      }
    }

    endPoint = event.canvasPosition;
    distance = vectorDistance(startPoint, endPoint) / 2;
    direction = ((startPoint - endPoint) / 2).normalized();
    force = ((direction * distance) * pushForce);

    ball.body.clearForces();
    ball.body.inertia = 0;

    trajectory.updateDots(ball.position, force);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if(firstTouch){
      if(!canPush)
      {
        return;
      }
    }

    ball.setActiveBody(true);

    ball.push(force);
    //ball.push((Vector2(0, -100) * pushForce));
    canPush =false;

    trajectory.setVisibility(false);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
  }

  @override
  void update(double dt)
  {
    super.update(dt);

    if(firstTouch){
      Rect visibleRect = camera.visibleWorldRect;
      if(ball.body.position.y > visibleRect.bottomCenter.toVector2().y){
        print("lose");
        Lose();
      }
    }
  }


  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();


    return [
      //Wall(topLeft, topRight),
      Wall(Vector2(topRight.x, -999999), Vector2(bottomRight.x, 9999)),

      Wall(Vector2(topLeft.x, -999999), Vector2(bottomLeft.x, 9999)),

      Wall(bottomRight, bottomLeft),
    ];
  }
}

class Hole extends BodyComponent{

  Hole(Vector2 pos, Vector2 tPos, double tAng)
  {
    position = Vector2(pos.x, pos.y);

    tempPos = tPos;
    tempAngle = tAng;
  }

  SpriteComponent s1 = SpriteComponent();
  SpriteComponent s2 = SpriteComponent();
  HoleTrigger holeTrigger = HoleTrigger(Vector2.zero());

  Vector2 tempPos = Vector2.all(-9999);
  double tempAngle = -9999;
  Vector2 position = Vector2.zero();

  void reset(){

    if(ball.body.position.x <= body.position.x)
    {
      setPosition((Vector2(12, ball.body.position.y - 15)), -30);
    }
    else
    {
      setPosition((Vector2(-12, ball.body.position.y - 15)), 30);
    }
  }

  void setPosition(Vector2 pos, double angle){
    s1.position = pos;
    s2.position = pos;
    body.setTransform(pos, radians(angle));
    s1.angle = radians(angle);
    s2.angle = radians(angle);
    holeTrigger.body.setTransform(pos, 0);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    renderBody = false;
    final front = await game.loadSprite('holeFront.png');
    final back = await game.loadSprite('holeBack.png');

    s1 = SpriteComponent(
        sprite: front,
        anchor: Anchor.center,
        scale: Vector2.all(0.08),
        priority: 4,
        position: position
    );
    s2 = SpriteComponent(
        sprite: back,
        anchor: Anchor.center,
        scale: Vector2.all(0.08),
        priority: 2,
        position: position
    );

    world.add(s1);
    world.add(s2);

    world.add(holeTrigger);
  }

  @override
  void onMount() {
    super.onMount();
    if(tempPos != Vector2.all(-9999) && tempAngle != -9999)
    {
      setPosition(tempPos, tempAngle);
    }
    game.placeHoles();
  }

  @override
  Body createBody() {
    
    Vector2 collisionScale = Vector2(.95,1);
    Vector2 collisionOffset = Vector2(0,-3);

    final shape = ChainShape();
    final vertices = [
      Vector2((-7 * collisionScale.x) + collisionOffset.x, (0 * collisionScale.y) + collisionOffset.y),
      Vector2((-4 * collisionScale.x) + collisionOffset.x, (7 * collisionScale.y) + collisionOffset.y),
      Vector2((4 * collisionScale.x) + collisionOffset.x, (7 * collisionScale.y) + collisionOffset.y),
      Vector2((7 * collisionScale.x) + collisionOffset.x, (0 * collisionScale.y) + collisionOffset.y),

      Vector2((3 * collisionScale.x) + collisionOffset.x, (6 * collisionScale.y) + collisionOffset.y),
      Vector2((-3 * collisionScale.x) + collisionOffset.x, (6 * collisionScale.y) + collisionOffset.y),
    ];
    shape.createLoop(vertices);

    FixtureDef fixtureDef = FixtureDef(shape, friction: .3);
    BodyDef bodyDef = BodyDef(userData: this, position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class HoleTrigger extends BodyComponent with ContactCallbacks{

  HoleTrigger(Vector2 pos)
  {
    position = Vector2(pos.x, pos.y);
  }

  Vector2 position = Vector2.zero();
  bool canEndContact = true;
  bool canContact = true;

  void beginContact(Object other, Contact contact) {
    if (other is Ball) {
      if(canContact){
        canContact = false;
        game.addHole();
        game.canPush = true;
        game.firstTouch = true;

        score++;
        textComponent.text = "Score: " + score.toString();

        if(score > maxScore){
          game.preferences?.setInt("MaxScore", score);
          maxScore = game.preferences!.getInt("MaxScore")!;
          print(maxScore);
        }
      }
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ball) {
      if(canEndContact)
      {
        canEndContact = false;
      }
    }
  }

  @override
  Body createBody() {
    renderBody = false;
    FixtureDef fixtureDef = FixtureDef(CircleShape()..radius = 4 , friction: .3, isSensor: true);
    BodyDef bodyDef = BodyDef(userData: this, position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class TrajectoryDot extends BodyComponent {

  TrajectoryDot(Vector2 pos)
  {
    position = Vector2(pos.x, pos.y);
  }

  Vector2 position = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = true;
  }

  @override
  void onMount() {
    super.onMount();

    print(body.position);
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(CircleShape()..radius = 1, friction: .3, isSensor: true);
    BodyDef bodyDef = BodyDef(userData: this, position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Trajectory{
  List<TrajectoryDot> dots = [];

  Vector2 pos = Vector2.zero();
  void prepareDots(List<TrajectoryDot> initDots){
    dots = initDots;
    setVisibility(false);
  }

  void updateDots(Vector2 ballPos, Vector2 forceApplied)
  {
    for (int i = 0; i < dots.length; i++) {
      double time = i * 0.1;
      Vector2 pos = Vector2(0, 0);
      pos = ballPos + ((forceApplied/pushForce)) * time + gravity * time * time / 2;
      dots[i].body.setTransform(pos, 0);
    }
  }

  void setVisibility(bool val)
  {
    dots.forEach((element) {element.opacity = (val ? 1 : 0);});
  }

}

class Ball extends BodyComponent with TapCallbacks {

  bool firstTime = true;
  bool firstTickCompleted = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    priority = 3;
    final sprite = await game.loadSprite('ball.png');
    add(
      SpriteComponent(
          sprite: sprite,
          anchor: Anchor.center,
          scale: Vector2.all(0.03),
      ),
    );
  }


  void setActiveBody(bool val){
    body.linearVelocity = Vector2.zero();
    body.setType(val ? BodyType.dynamic : BodyType.static);
    body.clearForces();
    body.inertia = 0;
    body.setActive(val);
  }

  void push(Vector2 force)
  {

    body.clearForces();
    body.linearVelocity = Vector2.zero();
    body.inertia = 0;
    body.applyForce((force*13) * 1);


    //body.applyLinearImpulse(force);
  }


  @override
  void update(double dt) {
    super.update(dt);
    if(!firstTickCompleted){

      firstTickCompleted = true;
    }

  }

  @override
  void onMount() async {
    super.onMount();
    // MassData massData = MassData();
    // massData.mass = 1;
    // body.setMassData(massData);
    //
    //
    // setActiveBody(false);
   // setActiveBody(false);
    //game.camera.moveTo(Vector2(0, ball.body.position.y - 30), speed: 15);

    MassData massData = MassData();
    massData.mass = 1;
    body.setMassData(massData);
    // push(Vector2(0, 1000000));
   

    await Future.delayed(const Duration(milliseconds: 100), ()=>{
      push(Vector2(0, -10000))
      //setActiveBody(false)
    });
    await Future.delayed(const Duration(milliseconds: 100), ()=>{

      setActiveBody(false)
    });
  }

  @override
  Body createBody() {
    FixtureDef fixtureDef = FixtureDef(CircleShape()..radius = 4, friction: .45, restitution: 0.35, density: 1);
    BodyDef bodyDef = BodyDef(userData: this, position: Vector2(-8,20), type: BodyType.dynamic);


    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

}


class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

double vectorDistance(Vector2 v1, Vector2 v2) {
  return sqrt(pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2));
}