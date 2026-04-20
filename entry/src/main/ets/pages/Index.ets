// 定义接口
interface Bullet {
  x: number;
  y: number;
}

interface Enemy {
  x: number;
  y: number;
  hp: number;
}

@Entry
@Component
struct ThunderFighter {
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  @State playerX: number = 165;
  @State playerY: number = 550;
  @State score: number = 0;
  @State gameOver: boolean = false;
  @State message: string = '战斗开始！';
  private GAME_WIDTH: number = 360;
  private GAME_HEIGHT: number = 600;

  // 子弹数组
  private bullets: Bullet[] = [];
  // 敌机数组
  private enemies: Enemy[] = [];
  // 游戏循环定时器
  private gameTimer: number = -1;
  // 敌机生成计数器
  private enemySpawnCounter: number = 0;

  resetGame() {
    this.playerX = 165;
    this.playerY = 550;
    this.score = 0;
    this.gameOver = false;
    this.message = '战斗开始！';
    this.bullets = [];
    this.enemies = [];
    this.enemySpawnCounter = 0;
    this.drawGame();
  }

  drawGame() {
    this.context.clearRect(0, 0, this.GAME_WIDTH, this.GAME_HEIGHT);

    // 画星星
    this.context.fillStyle = '#ffffff';
    for (let i = 0; i < 20; i++) {
      this.context.fillRect(i * 20, (i * 30 + this.score * 2) % this.GAME_HEIGHT, 2, 2);
    }

    // 画子弹
    this.context.fillStyle = '#ffff00';
    for (let bullet of this.bullets) {
      this.context.fillRect(bullet.x, bullet.y, 4, 10);
    }

    // 画敌机
    for (let enemy of this.enemies) {
      this.context.fillStyle = enemy.hp > 1 ? '#ff6600' : '#ff0000';
      this.context.fillRect(enemy.x, enemy.y, 25, 25);
      this.context.fillStyle = '#000000';
      this.context.fillRect(enemy.x + 8, enemy.y + 5, 8, 8);
    }

    // 画玩家
    if (!this.gameOver) {
      this.context.fillStyle = '#ffffff';
      this.context.fillRect(this.playerX, this.playerY, 30, 30);
      this.context.fillStyle = '#88ccff';
      this.context.fillRect(this.playerX - 5, this.playerY + 10, 5, 10);
      this.context.fillRect(this.playerX + 30, this.playerY + 10, 5, 10);
      this.context.fillStyle = '#ffdd00';
      this.context.fillRect(this.playerX + 10, this.playerY + 5, 10, 10);
    }

    // 游戏结束文字
    if (this.gameOver) {
      this.context.fillStyle = '#ff0000';
      this.context.font = '24px sans-serif';
      this.context.fillText('GAME OVER', 80, 300);
    }
  }

  gameUpdate() {
    if (this.gameOver) return;

    // 子弹移动
    for (let i = this.bullets.length - 1; i >= 0; i--) {
      this.bullets[i].y -= 8;
      if (this.bullets[i].y < 0) {
        this.bullets.splice(i, 1);
      }
    }

    // 敌机移动
    for (let i = this.enemies.length - 1; i >= 0; i--) {
      this.enemies[i].y += 3;
      if (this.enemies[i].y > this.GAME_HEIGHT) {
        this.gameOver = true;
        this.message = '敌机突破防线！';
      }
    }

    // 子弹碰撞敌机
    for (let i = this.bullets.length - 1; i >= 0; i--) {
      for (let j = this.enemies.length - 1; j >= 0; j--) {
        let bullet = this.bullets[i];
        let enemy = this.enemies[j];

        if (bullet.x >= enemy.x && bullet.x <= enemy.x + 25 &&
          bullet.y >= enemy.y && bullet.y <= enemy.y + 25) {
          this.bullets.splice(i, 1);
          enemy.hp--;

          if (enemy.hp <= 0) {
            this.enemies.splice(j, 1);
            this.score += 10;
            this.message = `击毁！+10分`;
          }
          break;
        }
      }
    }

    // 玩家碰撞敌机
    for (let enemy of this.enemies) {
      if (this.playerX < enemy.x + 25 && this.playerX + 30 > enemy.x &&
        this.playerY < enemy.y + 25 && this.playerY + 30 > enemy.y) {
        this.gameOver = true;
        this.message = '撞机了！';
        break;
      }
    }

    // 生成敌机
    this.enemySpawnCounter++;
    if (this.enemySpawnCounter >= 30) {
      this.enemySpawnCounter = 0;
      let hp: number = Math.random() > 0.7 ? 2 : 1;
      let enemy: Enemy = {
        x: Math.floor(Math.random() * (this.GAME_WIDTH - 30)),
        y: -30,
        hp: hp
      };
      this.enemies.push(enemy);
    }

    this.drawGame();
  }

  startGameLoop() {
    if (this.gameTimer === -1) {
      this.gameTimer = setInterval(() => {
        this.gameUpdate();
      }, 30);
    }
  }

  stopGameLoop() {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer);
      this.gameTimer = -1;
    }
  }

  movePlayer(dx: number, dy: number) {
    if (this.gameOver) return;

    let newX = this.playerX + dx;
    let newY = this.playerY + dy;

    if (newX >= 0 && newX <= this.GAME_WIDTH - 30) {
      this.playerX = newX;
    }
    if (newY >= 0 && newY <= this.GAME_HEIGHT - 30) {
      this.playerY = newY;
    }

    this.drawGame();
  }

  fire() {
    if (this.gameOver) return;

    let bullet: Bullet = {
      x: this.playerX + 13,
      y: this.playerY - 10
    };
    this.bullets.push(bullet);
    this.message = `发射！`;
    this.drawGame();
  }

  build() {
    Scroll() {
      Column({ space: 5 }) {
        Text('⚡ 雷霆战机 ⚡')
          .fontSize(20)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .margin({ top: 5, bottom: 2 })

        Canvas(this.context)
          .width(this.GAME_WIDTH)
          .height(this.GAME_HEIGHT)
          .backgroundColor('#0a0a2e')
          .border({ width: 1, color: '#4444aa' })
          .onReady(() => {
            this.drawGame();
            this.startGameLoop();
          })

        Row() {
          Text(`🏆 ${this.score}`)
            .fontSize(16)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
          Text(this.message)
            .fontSize(12)
            .fontColor('#ffffff')
            .margin({ left: 10 })
            .maxLines(1)
        }
        .width('100%')
        .padding(5)
        .justifyContent(FlexAlign.SpaceBetween)

        Column({ space: 5 }) {
          Button('⬆️ 上')
            .width(70)
            .height(40)
            .fontSize(16)
            .backgroundColor('#3366cc')
            .onClick(() => { this.movePlayer(0, -20); })

          Row({ space: 5 }) {
            Button('⬅️ 左')
              .width(70)
              .height(40)
              .fontSize(16)
              .backgroundColor('#3366cc')
              .onClick(() => { this.movePlayer(-20, 0); })

            Button('⬇️ 下')
              .width(70)
              .height(40)
              .fontSize(16)
              .backgroundColor('#3366cc')
              .onClick(() => { this.movePlayer(0, 20); })

            Button('➡️ 右')
              .width(70)
              .height(40)
              .fontSize(16)
              .backgroundColor('#3366cc')
              .onClick(() => { this.movePlayer(20, 0); })
          }

          Row({ space: 5 }) {
            Button('🔥 开火')
              .width(100)
              .height(45)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#cc3333')
              .onClick(() => { this.fire(); })

            Button('🔄 新游戏')
              .width(90)
              .height(45)
              .fontSize(14)
              .backgroundColor('#228822')
              .onClick(() => {
                this.stopGameLoop();
                this.resetGame();
                this.startGameLoop();
              })
          }
        }
        .margin({ top: 5 })
      }
      .width('100%')
      .backgroundColor('#1a1a3e')
      .padding({ bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a3e')
    .scrollable(ScrollDirection.Vertical)
  }
}