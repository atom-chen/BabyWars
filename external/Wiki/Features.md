## 战场界面
战场界面就是玩家进行对战走局时所看到的界面（对应代码中的SceneWar.lua）。

### 光标
原作的界面上有一个光标，可以在地图上移动，以及用于选中某建筑或单位和进行相应操作。  
在无触摸的情况下，光标是必须的，否则玩家不知道自己目前的操作焦点在哪里；但在本作中，由于允许触摸，玩家可以随时点击他所看到的任何东西，所以光标暂时显得没有必要。

本作暂不打算实现光标。

### 战场信息与操作菜单的呈现
战场上的某些信息会对玩家的思考产生直接影响，且会随着战局发展而频繁变化，因此界面上应当显示这些信息（至少在空闲状态下）。  
这些信息至少包括：
  - 当前玩家持有的金钱数量
  - 当前玩家使用的CO的能量槽
  - 焦点单位的血量、燃料、弹药
  - 焦点地形的防御补正、血量

至于战场操作菜单，它至少应当包含以下几项菜单项：
  - 打开详细战场信息（如CO信息、部队列表等）的界面
  - 激活CO技能
  - 退出战场

考虑到手机屏幕空间本就有限，应当尽量减少UI对屏幕空间的占用。因此，在空闲状态下，界面应该只显示战场信息，在玩家点击该信息时再呼出战场操作菜单。

显示战场信息的方式有以下几种：
  - 在屏幕中开辟某个固定区域（如右侧），不显示地图，只显示战场信息和操作按钮  
  这种方式的优点是实现简单（因为不需要考虑信息栏对地图的遮挡），缺点则是不够美观（因为留空区域大小有限不容易很好地显示信息，而且视觉上就是一条黑边）。
  - 战场信息做成HUD，在地图上浮动显示（类似原版游戏）  
  这种方式的优缺点与上面的正好相反。因为信息栏会遮挡部分地图，所以需要考虑根据玩家的操作，在适当时候自动调整信息栏的位置。
  
为了美观，本作将采用战场信息在地图上浮动显示的方式。
  
## 单位行动
  一个单位的一次行动可能包括一个或多个步骤，比如移动，移动+攻击，移动+占领，等等。所有的步骤都由玩家自行选择。  
  在玩家激活某个单位后、计划并确认当前行动中的所有步骤之前，玩家可以随意修改任意步骤；确认后，单位就按照这些步骤行动，玩家不能半途取消。
  
  这种操作方式可以避免玩家在雾战中试探地图，而且可以方便地把所有会对战局产生影响的计算彻底交由服务器进行（玩家修改步骤的计算可以在客户端进行，确认步骤后，客户端把步骤上传到服务器，服务器计算出这些步骤产生的结果并返回给客户端呈现），避免作弊。
  
## 在线对战
  所有会影响战局的计算都交由服务器进行，客户端只负责把玩家的操作上传，以及呈现服务器的计算结果。  
  换言之，如果用MVC的视角来看待战局，那么M在服务器上，VC在客户端上。
  
优点：
- 游戏不需要对玩家是否同时在线加以区分  
  玩家建立战局后，不管他们当中是否有人离线，对其余玩家以及服务器都没有实质影响（当然，为避免对战过长，双方可以事前设定多长时间内必须走局）。  
  当该玩家重新上线，则客户端根据当时战局的情况，进行合适的呈现即可。
- 最大限度杜绝作弊  
  服务器只把玩家当前可见的单位和地形信息推送到客户端，从根源上杜绝玩家通过破解数据，获知他所不应知道的信息的可能性。同时，客户端也无法干涉服务器的计算，从而保证对战公平。

缺点：
- 玩家必须有网络才能游玩——也就是说，不存在“离线对战”  
  假设允许玩家在无网络的情况下行动一回合，那么客户端必须首先从服务器上获取战局数据（把战局直接放在客户端上？Are you kidding？）。  
  即使忽略获取数据就必须要求有网络这一问题，在数据下载后，恶意玩家就有可能对战局数据进行破解——也就是说，玩家可能直接看到雾战中本应隐藏的敌方单位。  
  总之，离线对战既不完全离线，也不能保证对局无作弊，因此本作放弃离线对战。