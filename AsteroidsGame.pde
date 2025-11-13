import java.util.ArrayList;

color outlines = color(150, 230, 255);
float iframes = 0;
float MaxX = 2000;
float MinX = -2000;
float MaxY = 2000;
float MinY = -2000;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
ArrayList<TextParticle> textParticles = new ArrayList<TextParticle>();
Spaceship player = new Spaceship(0, 0, 0, 0, 0, 40);
Borders borders = new Borders();

float[] ray = new float[] {0,0,0,0};
float rayCharge = 50;
float playerControl = 0;
int score = 0;
int highScore = 0;
String UIstate = "menu";
boolean Up, ShiftP = false;
double bounceCooldown = 0;
float[] screenShake = new float[2];
float multiplier = 1;

void setup()
{
    frameRate(120);
    size(800,800);
    reset();

    for(int i = 0; i < 200; i++)
    {
        double x = (Math.random()*2*MaxX)+MinX;
        double y = (Math.random()*2*MaxY)+MinY;
        stars.add(new Star(x, y, 0, 0, 0, 100));
    }   
}
void reset()
{
    player = new Spaceship(0, 0, 0, 0, 0, 100);
    bullets.clear();
    asteroids.clear();
    for(int i = 0; i < 30; i++)
    {
        double x = (Math.random()*2*MaxX)+MinX;
        double y = (Math.random()*2*MaxY)+MinY;
        double Vx = Math.random()*200-100;
        double Vy = Math.random()*200-100;
        asteroids.add(new Asteroid(x, y, Vx, Vy, 0, 10, 30));
    }
    for(int i = 0; i < 10; i++)
    {
        double x = (Math.random()*2*MaxX)+MinX;
        double y = (Math.random()*2*MaxY)+MinY;
        double Vx = Math.random()*200-100;
        double Vy = Math.random()*200-100;
        asteroids.add(new Chaser(x, y, Vx, Vy, 0, 10, 30));
    }
    UIstate = "menu";
    if(score > highScore) highScore = score;
    score = 0;
}
void draw()
{ 
    if(UIstate == "play")
    {
        float playerSpeed = (float)Math.hypot(player.getVx(), player.getVy());
        multiplier = 1 + (playerSpeed/1500);
        if(screenShake[0] > 0) screenShake[0] -= 1/frameRate;
        else screenShake[0] = 0;
        pushMatrix();
        translate((float)Math.random()*(screenShake[0]*screenShake[1])-screenShake[0]*(screenShake[1]/2), (float)Math.random()*(screenShake[0]*screenShake[1])-screenShake[0]*(screenShake[1]/2));
        if(player.isDead()) reset();
        background(0,0,100);
        player.updatePosition();
        player.controls();
        player.show();
        iframes -= 1/frameRate;
        if(iframes < 0) iframes = 0;


        if(ray[3]>0)
        {
            pushMatrix();
            translate(width/2, height/2);
            translate(ray[0] - (float) player.getX(), ray[1] - (float) player.getY());
            stroke(255);
            strokeWeight(3);
            rotate(ray[2]);
            line(0, 0, 10000, 0);
            popMatrix();
        }
        ray[3] -= 1/frameRate;
        if (ray[3]<0) ray[3] = 0;
        
        for(int i = asteroids.size() - 1; i >= 0; i--)
        {
            Asteroid a = asteroids.get(i);
            if(a.isDead() && a.getSize() > 10)
            {
                if(a instanceof Chaser)
                {
                    asteroids.add(new Chaser(a.getX(), a.getY(), a.getVx()+Math.random()*100-50, a.getVy()+Math.random()*100-50, 0, (int)(a.getSize()/3), a.getSize() - 10));
                    asteroids.add(new Chaser(a.getX(), a.getY(), a.getVx()+Math.random()*100-50, a.getVy()+Math.random()*100-50, 0, (int)(a.getSize()/3), a.getSize() - 10));
                }        
                else
                {
                    asteroids.add(new Asteroid(a.getX(), a.getY(), a.getVx()+Math.random()*100-50, a.getVy()+Math.random()*100-50, 0, (int)(a.getSize()/3), a.getSize() - 10));
                    asteroids.add(new Asteroid(a.getX(), a.getY(), a.getVx()+Math.random()*100-50, a.getVy()+Math.random()*100-50, 0, (int)(a.getSize()/3), a.getSize() - 10));
                }        
            }

            if (a.isDead())
            {
                score += 10*multiplier;
                textParticles.add(new TextParticle(a.getX(), a.getY(), 0, 0, 0, 1, "10"));
                asteroids.remove(i);
            }
            a.updatePosition();
            a.show();
            a.collision();
        }
        for(int i = bullets.size() - 1; i >= 0; i--)
        {
            Bullet a = bullets.get(i);
            a.updatePosition();
            a.show();
            a.collision();
            if(a.isDead()) bullets.remove(i);
        }
        for(Star s : stars)
        {
            s.show();
        }
        for(int i = textParticles.size() - 1; i >= 0; i--)
        {
            TextParticle a = textParticles.get(i);
            a.updatePosition();
            a.show();
            if(a.isDead()) textParticles.remove(i);
        }  
        borders.show();
        if(bounceCooldown>0)    bounceCooldown -= 1/frameRate;
        else bounceCooldown = 0;
        popMatrix();
    }    
    UI();
    
}
void mousePressed()
{
    if(mouseButton == LEFT && UIstate == "play")  player.fire();
}

void keyPressed()
{
    if(UIstate == "menu") 
    {
        if(keyCode == 32)
        {
            UIstate = "play";
        }
    }
    if(key == 'w')    Up = true;
    if(keyCode == SHIFT && bounceCooldown == 0)
    {
        player.bounce();
        bounceCooldown = 100/Math.abs((Math.hypot(player.getVx(), player.getVy()))*.5);
    }    
}

void keyReleased()
{
    if(key == 'w')    Up = false;
}




class Asteroid extends Floater
{
    protected float size;
    protected float hitFlash;
    Asteroid(double x, double y, double Vx, double Vy, double direction, double health, float size)
    {
        super(x, y, Vx, Vy, direction, health);
        this.size = size;
        this.hitFlash = 0;
    }
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        translate((float) x - (float) player.getX(), (float) y - (float) player.getY());
        rotate((float)direction);
        stroke(outlines);
        if(hitFlash > 0)
        {
            stroke(150/2, 230/2, 255/2);  
        }
        strokeWeight(1);
        ellipse(0, 0, size, size);
        popMatrix();
    }
    public void collision()
    {
        if(Math.hypot(player.getX() - x, player.getY() - y) < size/2 && iframes == 0)    
        {
            screenShake[0] = .5;
            screenShake[1] = 15;
            iframes = 2;
            playerControl = .5f;
            player.health -= 10;
            player.Vx = -player.Vx*.9 + Vx*1.1;
            player.Vy = -player.Vy*.9 + Vy*1.1;
        }
        for(Asteroid a : asteroids)
        {
            if(a != this)
            {
                if(Math.hypot(a.getX() - x, a.getY() - y) < (size/2 + a.getSize()/2))
                {
                    double angle = atan2((float)(a.getY() - y), (float)(a.getX() - x));
                    double totalMass = size + a.getSize();
                    double newVx1 = (Vx * (size - a.getSize()) + (2 * a.getSize() * a.getVx())) / totalMass;
                    double newVy1 = (Vy * (size - a.getSize()) + (2 * a.getSize() * a.getVy())) / totalMass;
                    double newVx2 = (a.getVx() * (a.getSize() - size) + (2 * size * Vx)) / totalMass;
                    double newVy2 = (a.getVy() * (a.getSize() - size) + (2 * size * Vy)) / totalMass;
                    Vx = newVx1;
                    Vy = newVy1;
                    a.setVx(newVx2);
                    a.setVy(newVy2);
                    double overlap = (size/2 + a.getSize()/2) - Math.hypot(a.getX() - x, a.getY() - y);
                    x -= Math.cos(angle) * (overlap / 2);
                    y -= Math.sin(angle) * (overlap / 2);
                    a.x += Math.cos(angle) * (overlap / 2);
                    a.y += Math.sin(angle) * (overlap / 2);
                }
            }
        }   
    }
    public void updatePosition()
    {
        super.updatePosition();
        if(hitFlash > 0) hitFlash -= 1/frameRate;
        else hitFlash = 0;
    }
    float getSize() {return size;}
    float getHitFlash() {return hitFlash;}
    void setVx(double Vx) {this.Vx = Vx;}
    void setVy(double Vy) {this.Vy = Vy;}
    void setHitFlash(float hitFlash) {this.hitFlash = hitFlash;}
}

class Chaser extends Asteroid
{
    protected boolean chasing = false;
    Chaser(double x, double y, double Vx, double Vy, double direction, double health, float size)
    {
        super(x, y, Vx, Vy, direction, health, size);
        this.chasing = false;
    }
    public void updatePosition()
    {

        double px = player.getX();
        double py = player.getY();
        double pvx = player.getVx();
        double pvy = player.getVy();
        double dx = px - x;

        double dy = py - y;
        double distanceToPlayer = Math.hypot(dx, dy);

        double speed = Math.hypot(Vx, Vy);

        double maxSpeed = 200 + player.speed; 
        double maxAccel = 500;               
        double maxPrediction = 2.0;           

        double playerSpeed = Math.hypot(pvx, pvy);
        double closingSpeed = speed + playerSpeed;
        double predictTime = 0;    
        super.updatePosition();
        if(Math.random() < 0.01 && frameCount % 20 == 0)
        {
            chasing = !chasing;
        }
        if(chasing)
            {

                if (closingSpeed > 1e-6) {
                    predictTime = distanceToPlayer / closingSpeed;
                }
                predictTime = Math.max(0, Math.min(predictTime, maxPrediction));

                if (distanceToPlayer < 200) {
                    predictTime = 0;
                }

                double targetX = px + pvx * predictTime;
                double targetY = py + pvy * predictTime;

                double desiredX = targetX - x;
                double desiredY = targetY - y;
                double desiredDist = Math.hypot(desiredX, desiredY);

                double desiredVx = 0;
                double desiredVy = 0;
                if (desiredDist > 1e-6) {
                    
                    double desiredSpeed = maxSpeed;
                    if (distanceToPlayer < 250) {
                        desiredSpeed = Math.max(120, maxSpeed * (distanceToPlayer / 250.0));
                    }
                    desiredVx = desiredX / desiredDist * desiredSpeed;
                    desiredVy = desiredY / desiredDist * desiredSpeed;
                }
                double steerX = desiredVx - Vx;
                double steerY = desiredVy - Vy;
                double maxDeltaV = maxAccel / frameRate;
                double steerMag = Math.hypot(steerX, steerY);
                if (steerMag > maxDeltaV && steerMag > 1e-9) {
                    steerX = steerX / steerMag * maxDeltaV *(1+Math.random()*0.5);
                    steerY = steerY / steerMag * maxDeltaV *(1+Math.random()*0.5);
                }

                Vx += steerX;
                Vy += steerY;
            }

        double newSpeed = Math.hypot(Vx, Vy);
        if (newSpeed > maxSpeed && newSpeed > 1e-9) {
            double a = Math.atan2(Vy, Vx);
            Vx = Math.cos(a) * maxSpeed;
            Vy = Math.sin(a) * maxSpeed;
        }
    }
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        translate((float) x - (float) player.getX(), (float) y - (float) player.getY());
        rotate((float)direction);
        stroke(150,255, 150);
        if(hitFlash > 0)
        {
            stroke(150/2, 230/2, 255/2);  
        }
        strokeWeight(1);
        ellipse(0, 0, size, size);
        popMatrix();
    }    
}   
class Bullet extends Floater
{
    Bullet(double x, double y, double Vx, double Vy, double direction, double health)
    {
        super(x, y, Vx, Vy, direction, health);
    }
    public void show()
    {
        health -= 1/frameRate;
        pushMatrix();
        translate(width/2, height/2);
        translate((float) x - (float) player.getX(), (float) y - (float) player.getY());
        rotate((float)direction);
        stroke(outlines);
        strokeWeight(1);
        ellipse(0, 0, 5, 5);
        popMatrix();
    }
    public void collision()
    {
        for (int i = asteroids.size() - 1; i >= 0; i--)
        {
            Asteroid a = asteroids.get(i);
            
            if(Math.hypot(a.getX() - x, a.getY() - y) < a.getSize()/2)
            {
                if(Math.hypot(player.getX() - x, player.getY() - y) < 150)
                screenShake[0] = .5;
                screenShake[1] = 5;
                health = 0;
                hit(a, 1);    
            }
        }
    }

}

void hit(Asteroid a, double damage)
{
                
    if (a.getHealth() > 0 && a.getHitFlash() == 0)
    {
        a.health -= damage;
        a.setHitFlash(0.1f);
        textParticles.add(new TextParticle(a.getX(), a.getY(), 0, 0, 0, 1, (int)(-damage)));
    }

}
{

}
void ray()
{
    for(Asteroid a : asteroids)
    {

        double angleToAsteroid = atan2(a.getY() - player.getY(), a.getX() - player.getX());
        double angleDiff = radians(Math.min(Math.abs((float)(degrees((float)angleToAsteroid) -  degrees((float)player.direction))), 360 - Math.abs((float)(degrees((float)angleToAsteroid) -  degrees((float)player.direction)))));
        float distanceToAsteroid = (float)Math.hypot(a.getX() - player.getX(), a.getY() - player.getY());
        rayCharge = 50;
        if(angleDiff <  atan2(a.getSize()/2, distanceToAsteroid))
        {
            hit(a, 10);
        }
        ray[0] = player.getX();
        ray[1] = player.getY();
        ray[2] = (float)player.direction;
        ray[3] = 1;
   
    }
}  
    
class Borders
{
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        translate(-(float) player.getX(), -(float) player.getY());
        noFill();
        stroke(150,150,255);
        strokeWeight(1);
        rect(MinX, MinY, MaxX - MinX, MaxY - MinY);
        popMatrix();
    }
}

void UI()
{   
    if(UIstate == "play")
    {
        strokeWeight(5);
        textAlign(CENTER);
        textSize(100);
        text(nf(Math.round(multiplier * 100.0) / 100.0) + "X", width*.1, height*.1);
        line(20, height*.95, 20+((float)bounceCooldown*200), height*.95);
        line(20, height*.9, 20+((float)player.getHealth()*3), height*.9);
    }
    if(UIstate == "menu")
    {
        background(0,0,100);
        textSize(100);
        text("Asteroids", width/10, height/10);
        textSize(50);
        text("Highscore: " + highScore, width/10, height/7);
        textSize(30);
        text("press space to start", width/10, height/2);
    }
}
class TextParticle extends Floater
{
    protected String ttext;
    TextParticle(double x, double y, double Vx, double Vy, double direction, double health, String text)
    {
        super(x, y, Vx, Vy, direction, health);
        this.text = ttext;
    }
    TextParticle(double x, double y, double Vx, double Vy, double direction, double health, int number)
    {
        super(x, y, Vx, Vy, direction, health);
        if (number < 0) this.ttext = nf(number);
        else this.ttext = "+" + number;
        
    }
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        translate((float) x - (float) player.getX(), (float) y - (float) player.getY());
        stroke(outlines);
        textSize(20);
        textAlign(CENTER);
        text(ttext, 0, 0);
        popMatrix();
    }
    public void updatePosition()
    {
        super.updatePosition();
        health -= 1/frameRate;
    }          
}
