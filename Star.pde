class Star extends Floater
{
    Star(double x, double y, double Vx, double Vy, double direction, double health)
    {
        super(x, y, Vx, Vy, direction, health);
    }
    public void show()
    {
        pushMatrix();
        translate(width/2, height/2);
        translate((float) x - (float) player.getX(), (float) y - (float) player.getY());
        stroke(outlines);
        strokeWeight(3);
        point(0, 0);
        popMatrix();
    }
}
