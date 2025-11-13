class Floater
{
    protected double x, y, Vx, Vy, direction, health;
    Floater(double x, double y, double Vx, double Vy, double direction, double health)
    {
        this.x = x;
        this.y = y;
        this.Vx = Vx;
        this.Vy = Vy;
        this.direction = direction;
        this.health = health;
    }

    public void updatePosition()
    {
        
        x += Vx/frameRate;
        y += Vy/frameRate;

        //collision handling with borders
        if(x > MaxX || x < MinX) Vx = - Vx*1.2;
        if(y > MaxY || y < MinY) Vy = - Vy*1.2;
    }
    boolean isDead()
    {
        return health <= 0;
    }
    
    float getX() {return (float)x;}  float getVx() {return (float)Vx;}
    float getY() {return (float)y;}  float getVy() {return (float)Vy;}
    float getHealth() {return (float)health;}
}
