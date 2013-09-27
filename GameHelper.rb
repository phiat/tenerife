

def spriteCollide(object1, object2) 
    left1 = object1.x
    left2 = object2.x
    right1 = object1.x + object1.image.width
    right2 = object2.x + object2.image.width
    top1 = object1.y
    top2 = object2.y
    bottom1 = object1.y + object1.image.height
    bottom2 = object2.y + object2.image.height

    if (bottom1 < top2) 
      return false 
    end
    if (top1 > bottom2) 
      return false 
    end 

    if (right1 < left2) 
      return false 
    end
    if (left1 > right2) 
      return false 
    end

    return true
end