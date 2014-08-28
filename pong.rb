Shoes.app do
  @userScore, @compScore, @dx, INITIAL_SPEED, COMP_LEVEL, SPEED_BONUS1, SPEED_BONUS2 = 0, 0, 0, 8, 20, 10, 20
  @the=title("Score: SuckIt #{@userScore}  TheBadGuys #{@compScore}",size:   20, top:    height/2-40, align:  "center",font:   "Trebuchet MS", stroke: red)
  @paddle, @compPaddle, @ball = rect(480, 400, 100, 20), rect(width/2, 0, 100, 20), rect(width/2, height/2, 20, 20)
  @prevMove=@paddle.left

  motion do |left, top|
      @dx=left-@prevMove
      @paddle.move left, height- @paddle.height if left < width - @paddle.width
      @prevMove = @paddle.left
  end

  @riseSpeed, @runSpeed, @rise, @run, @riseDir, @runDir=INITIAL_SPEED, INITIAL_SPEED, height/2, width/2, 1, 1

  paddleLocation=@compPaddle.left
   animate(100) do
    mid=@compPaddle.left+@compPaddle.width/2
    ballDir=(@ball.left-mid)/(@ball.left-mid).abs
    paddleLocation+= (@runSpeed > COMP_LEVEL ? ballDir*COMP_LEVEL : ballDir*@runSpeed)
    @compPaddle.move paddleLocation, @compPaddle.top
   end

   @game=animate(200) do
      m=self.mouse[1]
      @dx=0 if (m>width-@paddle.width || m<=1 || @paddle.left<@paddle.width)
      userHit, compHit=hit(@ball,@paddle,@riseSpeed,0), hit(@ball,@compPaddle,@riseSpeed,1)

      if userHit[0] && @riseDir==1
        @rise=@paddle.top
        @run+=(@runSpeed * @runDir)/2
        @ball.move @run, @rise
        @riseDir*=-1
      elsif compHit[0] && @riseDir==-1
        @rise=@compPaddle.top+@compPaddle.height
        @run+=(@runSpeed * @runDir)/2
        @ball.move @run, @rise
        @riseDir*=-1
      else
        @rise+=@riseSpeed * @riseDir
        @run+=@runSpeed * @runDir
        @ball.move @run, @rise
      end

      @riseDir*=-1 if ((@ball.top > height - @paddle.height && userHit[0]) || (@ball.top < @compPaddle.height && compHit[0]))
      @runDir*=-1 if (@ball.left<=0 || @ball.left+@ball.width >= width-10)

      if (userHit[0])
        if ((@dx < 0 && @runDir < 0 ) || (@dx > 0 &&  @runDir > 0 ))
          @runSpeed += (userHit[1].abs/SPEED_BONUS1+@dx.abs/SPEED_BONUS2)/2
          @riseSpeed +=  (@dx.abs/SPEED_BONUS2+userHit[1].abs/SPEED_BONUS1)/2  
        end
        if ((@dx > 0 && @runDir < 0) || (@dx < 0 && @runDir > 0))
          @runSpeed -= (userHit[1].abs/SPEED_BONUS1+@dx.abs/SPEED_BONUS2)/4
          @riseSpeed -=  (@dx.abs/SPEED_BONUS2+userHit[1].abs/SPEED_BONUS1)/4
          @runDir*=-1   
        end
      end
      scores 0 if @ball.top < 0
      scores 1 if @ball.top > height  
   end
   
    def scores(player)
      (player==0 ? @userScore+=1 : @compScore+=1)
      @ball.hide
      (player==0 ? @ball = rect(@paddle.left+@paddle.width/2, height-@paddle.height-30, 20, 20) : @ball =  rect(@compPaddle.left+@compPaddle.width/2, @compPaddle.height+10, 20, 20) )
      (player==0 ? @rise = @compPaddle.height+10 : @rise = height-@paddle.height-30 )
      (player==0 ? @run = @compPaddle.left+@compPaddle.width/2 : @run = @paddle.left+@paddle.width/2 )
      (player==0 ? @riseDir=1 : @riseDir=-1)
      @the.text="Score: SuckIt #{@userScore}    TheBadGuys #{@compScore}"
      @runDir, @riseSpeed, @runSpeed= 1, INITIAL_SPEED, INITIAL_SPEED
    end
   def hit(rect1,rect2,inc,uC)
      cond1=(uC < 1 ? (rect1.top + rect1.height + inc > rect2.top) : (rect1.top - inc < rect2.top + rect2.height))
      angMomentum = ( cond1 ? (rect1.left+rect1.width/2)-(rect2.left+rect2.width/2) : 0)
      cond2=(rect1.left>=rect2.left && rect1.left<=rect2.left+rect2.width)
      cond3=(rect1.left+rect1.width>=rect2.left && rect1.left+rect1.width<=rect2.left+rect2.width)
      cond4=(cond2||cond3)
      return (cond1&&cond4), angMomentum
  end
 end
