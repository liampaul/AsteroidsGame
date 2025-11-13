class Spaceship extends Floater
{
    protected double speed = 80;
    Spaceship(double x, double y, double Vx, double Vy, double direction, double health)
    {
        super(x, y, Vx, Vy, direction, health);
    }
    public void controls()
    {
        if (mousePressed && mouseButton == RIGHT) rayCharge = (float)Math.max(rayCharge - (Math.hypot(Vx, Vy)/60)/frameRate, 0);
        else
        {
            if (rayCharge == 0) dray();
            if (rayCharge < 50) rayCharge += 40/frameRate;
            
        }
        playerControl -= 1/frameRate;
        if(playerControl < 0) playerControl = 0;
        double turnBonus = 1;
        double turnBonusMultiplier = 0.005;
        if (Vx !=0)
        {
            double angleDiff = Math.min(Math.abs((float)(degrees((float)direction) -  degrees(atan2((float)Vy, (float)Vx)))), 360 - Math.abs((float)(degrees((float)direction) -  degrees(atan2((float)Vy, (float)Vx)))));
            turnBonus = (1+(angleDiff * turnBonusMultiplier));
        }
        if(playerControl == 0)
        {
            if(Up)
            {

                Vx += ((cos((float)direction))/frameRate)*speed * turnBonus;
                Vy += ((sin((float)direction))/frameRate)*speed * turnBonus;
            }
        }  
        direction = Math.atan2((double)mouseY-(height/2), (double)mouseX-(width/2));
        text(score, 20, height*.6);
        
    }
 
    public void bounce()
    {
        double V = Math.hypot(Vx,Vy);
        Vx = V*cos((float)direction)*.9;
        Vy = V*sin((float)direction)*.9;
    }
    public void fire()
    {
 
        double bX = x + 10 * Math.cos(direction);
        double bY = y + 10 * Math.sin(direction);
        

        double bulletSpeed = 800; 
        double bVx = Vx + bulletSpeed * Math.cos(direction);
        double bVy = Vy + bulletSpeed * Math.sin(direction);

        bullets.add(new Bullet(bX, bY, bVx, bVy, direction, 10));

        Vx += -cos((float)direction) * 10;
        Vy += -sin((float)direction) * 10;
    }
    public void updatePosition()
    {
        super.updatePosition();
        if((x > MaxX || x < MinX)|| (y > MaxY || y < MinY))
        {
            screenShake[0] = .5;
            screenShake[1] = 20;
            playerControl = .5f;
        }
        double speedDirection = atan2((float)Vy, (float)Vx);
        double speedMagnitude = Math.hypot(Vx, Vy);
        if (speedMagnitude > 1250)
        {
            Vx = cos((float)speedDirection) * 1250;
            Vy = sin((float)speedDirection) * 1250;
        }
        if(speedMagnitude < 0.1)
        {
            Vx = 0;
            Vy = 0;
        }
    }
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        rotate((float)direction);
        stroke(150, 230, 255);
        if(iframes > 0)
        {
            stroke(150/2, 230/2, 255/2);
        }
        strokeWeight(1);
        ellipse(0, 0, 20, 10);
        stroke(150,150,255,50);
        line(10, 0, 10000, 0);
        if(rayCharge < 50)
        {
            strokeWeight(((100-rayCharge)/100)*2);
            pushMatrix();
            rotate(-radians(rayCharge));
            line(10, 0, 10000, 0);
            popMatrix();
            pushMatrix();
            rotate(radians(rayCharge));
            line(10, 0, 10000, 0);
            popMatrix();
        }
        popMatrix();
    }
    float getVx() {return (float)Vx;}
    float getVy() {return (float)Vy;}

}
