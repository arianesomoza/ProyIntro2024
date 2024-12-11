unit frmAliens;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Mask, Vcl.Buttons, pngimage, Vcl.MPlayer;


type


  TDireccion=(dIzq,dDer,dArr,dAba);



  TAlien=class
    private
      img:TImage; //aqui va la imagen y otro atributos
      t:byte; //tamaño
      v:Word;//velocidad
      ti:Word;//tiempo entre disparos
      d:TDireccion;
    public
      constructor Create(propietario:twincontrol);
      destructor  Destroy;
      procedure SetTamaño(tt:byte);
      procedure SetPosicion(x,y:integer);
      procedure SetImagen(nomArch:string);
      procedure SetX(xx:integer);
      procedure SetY(yy:integer);
      function  GetX:integer;
      function  GetY:integer;
      property  Tamaño:byte  read t write setTamaño;
      property  Tiempo:word read ti write ti;
      property  Velocidad:word read v write v;
      property  Direccion:TDireccion read d write d;
      property  x:integer read GetX write SetX;
      property  y:integer read GetY write SetY;
      procedure Mover;
  end;




  TNave=class
    private
      img:TImage; //aqui va la imagen y otro atributos
    public
      constructor Create(propietario:twincontrol);
      destructor  Destroy;
      procedure SetImagen(nomArch:string);
      procedure SetX(xx:integer);
      procedure SetY(yy:integer);
      procedure SetAlto(a:byte);
      procedure SetAncho(a:byte);
      function  GetX:integer;
      function  GetY:integer;
      function  GetAlto:byte;
      function  GetAncho:byte;
      property  x:integer read GetX write SetX;
      property  y:integer read GetY write SetY;
      property  Alto:byte read GetAlto write SetAlto;
      property  Ancho:byte read GetAncho write SetAncho;
      procedure Mover(d:TDireccion);
  end;






  TBala=class
    private
      img:TImage; //aqui va la imagen y otro atributos
      v:Word;//velocidad
      d:TDireccion;
    public
      constructor Create(propietario:twincontrol);
      destructor  Destroy;
      procedure SetAncho(a:byte);
      procedure SetAlto(a:byte);
      procedure SetImagen(nomArch:string);
      procedure SetX(xx:integer);
      procedure SetY(yy:integer);
      function  GetX:integer;
      function  GetY:integer;
      function  GetAlto:byte;
      function  GetAncho:byte;
      property  Ancho:byte read getAncho write setAncho;
      property  Alto:byte  read getAlto  write setAlto;
      property  Velocidad:word read v write v;
      property  Direccion:TDireccion read d write d;
      property  x:integer read GetX write SetX;
      property  y:integer read GetY write SetY;
      procedure Mover;
  end;








  //*** definicion de la clase del FORMULARIO (JUEGO) ******
  TForm1 = class(TForm)
    Timer1: TTimer;   //controla el aleteo de los aliens
    Timer2: TTimer;   //controla el movimiento de los aliens
    Image1: TImage;   //fondo de la pantalla
    Timer3: TTimer;
    Timer4: TTimer;
    Timer5: TTimer;
    MediaPlayer1: TMediaPlayer;
    MediaPlayer2: TMediaPlayer;
    MediaPlayer3: TMediaPlayer;   //controla el nacimiento de las balas
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer5Timer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    {los aliens}
    alienA:array[1..30] of TAlien;
    alienB:array[1..30] of TAlien;
    na:byte; //numero de aliens
    balas:array[1..255] of TBala; //contenedor de las balas
    nb:byte; //numero de balas
    cn: byte; //cantidad de nulos

    {la nave}
    nave:TNave;
    balaNave:array[1..4] of TBala;
    cantBalasNave: byte;
    movIzq, movDer, movArr, movAba: boolean;

  public
    { Public declarations }

    {funciones de los aliens}
    procedure Disparar(quien:TAlien);
    function  PosicionLibre:word;
    function HuboImpacto(quien:TBala):boolean;

    {funciones de la nave}
    procedure naveDisparar;
    function impactoNaveBala(bala: TBala; alien: TAlien): boolean;

  end;






var
  Form1: TForm1;

implementation




//------------------ MODO IMPLEMENTADOR -----------------





// ------------- IMPLEMENTANDO LA CLASE ALIEN ------------
destructor  TAlien.Destroy;
begin
  img.Free;
end;
procedure TAlien.Mover;
begin
  if d=dDer then begin
     x:=x+10;
  end else if d=dIzq then begin
     x:=x-10;
  end;
end;

procedure TAlien.SetX(xx: Integer);
begin
  img.Left:=xx;
end;
procedure TAlien.SetY(yy: Integer);
begin
  img.Top:=yy;
end;
function TAlien.GetX: Integer;
begin
  result:=img.Left;
end;
function TAlien.GetY: Integer;
begin
  result:=img.Top;
end;
constructor TAlien.Create(propietario:Twincontrol);
begin //inicializa
  img:=Timage.Create(propietario);
  img.Parent:=propietario;
  img.Stretch:=true;
  img.Top:=0; img.Left:=0;
  t:=60;  img.Width:=t; img.Height:=t;//tamaño del alien 60x60
  v:=300; //cada 300 ms dara un paso
  ti:=2000;//tiempo entre disparos del alien
end;
procedure TAlien.SetTamaño(tt:byte);
begin
  t:=tt; img.Width:=tt; img.Height:=tt;
end;
procedure TAlien.SetPosicion(x,y:integer);
begin
  img.Top:=y;
  img.Left:=x;
end;
procedure TAlien.SetImagen(nomArch:string);
var png: TPngImage;
begin
  png := TPngImage.Create;
  png.LoadFromFile(nomArch);
  img.picture.Assign(png);
end;


//*** IMPLEMENTACION DE LA CLASE NAVE ****


destructor  TNave.Destroy;
begin
  img.Free;
end;

constructor TNave.Create(propietario:twincontrol);
begin
  img:=TImage.Create(propietario);
  img.Parent:=propietario;
  img.Transparent	:= true;
  img.Left:=0; img.Top:=0; //(0,0)
  img.Width:=40; img.Height:=60;//40x60
  img.Stretch:=true;
end;


procedure TNave.SetImagen(nomArch:string);
var png: TPngImage;
begin
  png := TPngImage.Create;
  png.LoadFromFile(nomArch);
  img.picture.Assign(png);
end;


procedure TNave.SetX(xx:integer);
begin
  img.Left:=xx;
end;
procedure TNave.SetY(yy:integer);
begin
  img.top:=yy;
end;
procedure TNave.SetAlto(a:byte);
begin
  img.Height:=a;
end;
procedure TNave.SetAncho(a:byte);
begin
  img.Width:=a;
end;
function TNave.GetX:integer;
begin
  result:=img.Left;
end;
function TNave.GetY:integer;
begin
  result:=img.Top;
end;
function TNave.GetAlto:byte;
begin
  result:=img.Height;
end;
function TNave.GetAncho:byte;
begin
  result:=img.Width;
end;


   // direccionales de la nave


procedure TNave.Mover(d: TDireccion);
begin
  case d of
    dIzq: x := x - 7;   // Mueve a la izquierda
    dDer: x := x + 7;   // Mueve a la derecha
    dArr: y := y - 7;   // Mueve hacia arriba (hacia adelante)
    dAba: y := y + 7;   // Mueve hacia abajo
  end;
end;





//***** implementando la clase BALA *****




destructor  TBala.Destroy;
begin
  img.Free;
end;

constructor TBala.Create(propietario:twincontrol);
begin
  img:=TImage.Create(propietario);
  img.Parent:=propietario;
  img.Left:=0; img.Top:=0;
  img.Width:=5; img.Height:=20;
  d:=dArr;
end;
procedure TBala.SetAncho(a:byte);
begin
  img.Width:=a;
end;
procedure TBala.SetAlto(a:byte);
begin
  img.Height:=a;
end;
procedure TBala.SetImagen(nomArch:string);
begin
  img.Picture.LoadFromFile(nomArch);
end;
procedure TBala.SetX(xx:integer);
begin
  img.Left:=xx;
end;
procedure TBala.SetY(yy:integer);
begin
  img.Top:=yy;
end;
function TBala.GetX:integer;
begin
  result:=img.Left;
end;
function TBala.GetY:integer;
begin
  result:=img.Top;
end;
function TBala.GetAlto:byte;
begin
  result:=img.Height;
end;
function TBala.GetAncho:byte;
begin
  result:=img.Width;
end;

            // velocidad de las balas de los aliens

procedure TBala.Mover;         /// solo cambia el valor 15 por un numero mas alto
begin
  if d=dArr then begin
    y:=y-20;
  end else if d=dAba then begin
    y:=y+20;
  end;
end;

   //facil:10    normAL: 15   dificil:25   harcord: 40



{$R *.dfm}
//*** CONTROL DEL JUEGO ****** MODO USUARIO PROGRAMADOR

procedure TForm1.FormCreate(Sender: TObject);
var i:byte;
    x,y:word;
    sw:boolean;
begin

  borderstyle:=bsNone;      // quita el borde
   windowstate:=wsmaximized;   //maximinizar ventana


   na:=15; //comenzaremos con 12 aliens
   x:=100; //comenzaremos en la posicion 100
   y:=50; //iniciamos a 50 px del borde superior

   sw:=true;


   {Creacion de los aliens}
   for i:=1 to na do begin
     alienA[i]:=TAlien.Create(form1);
     alienA[i].x:=x;
     alienA[i].y:=y;
     alienA[i].SetImagen('./alien01.png');
     alienA[i].Tamaño:=60;
     alienA[i].Velocidad:=500; // velocidad de disparos de los balas de los aliens
     alienA[i].Tiempo:=700+random(7000);  //tiempo entre disparos
     alienA[i].Direccion:=dDer;//inicialmente se dirigen a la derecha
     alienA[i].img.Visible:=sw;

     sw:=not sw;

     alienB[i]:=TAlien.Create(form1);
     alienB[i].x:=x;
     alienB[i].y:=y;
     alienB[i].SetImagen('./alien10.png');
     alienB[i].Tamaño:=60;
     alienB[i].Velocidad:=500;
     alienB[i].Tiempo:=alienA[i].Tiempo; //tiempo restante
     alienB[i].Direccion:=dDer;
     alienB[i].img.Visible:=sw;
     x:=x+75;
   end;
   nb:=255; //mñxima cantidad de balas en pantalla
   cn := 0;
   {Configuaracion de los timer}
   timer1.Interval:=500; //aleteo cada 500 ms
   timer1.Enabled:=true;
   timer2.Interval:=alienA[1].Velocidad;//controla el movimiento alien
   timer2.Enabled:=true;
   timer3.Interval:=15; //cada 20ms se actualizaro el disparo
   timer3.Enabled:=true;


   {Creacion de la nave}
   nave:=TNave.Create(form1);
   nave.SetImagen('./nave.png');
   nave.Ancho:=50; nave.Alto:=75;
   nave.x:=width div 2 - 25-8;
   nave.y:=height - 150;
   cantBalasNave := 4;
   movIzq := false;
   movder := false;
   movArr := false;
   movAba := False;


   {creacion de la musica}

    //musica de fondo
    MediaPlayer1.FileName := 'music_fondo.mp3';
    MediaPlayer1.Open;
    MediaPlayer1.Play;
    MediaPlayer1.AutoRewind := true;

    MediaPlayer2.FileName := 'ufo_death.wav';   // su play esta donde explota el aliens
    MediaPlayer2.Open;

    MediaPlayer3.FileName := 'defender_death.mp3'; // su play esta donde explota la nave
    MediaPlayer3 .Open;

end;


{Logica para liberar la memoria}
procedure TForm1.FormDestroy(Sender: TObject);
VAR I:BYTE;
begin

   {Liberal los aliens}
   for i:=1 to na do begin
     if Aliena[i]<>nil then begin
        alienA[i].Free;
        alienB[i].Free;
     end;
   end;

   {Liberar la nave y las balas}
   nave.Free;
   for i:= 1 to nb do begin
     if balas[i]<>nil then
        balas[i].Free;
   end;

   {libera las balas de la nave}
   for i := 1 to cantBalasNave do begin
      if balaNave[i]<>nil then
        balaNave[i].Free;
   end;


end;


{Logica para mover la nave}
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  case key of
    vk_left: movIzq := true;
    vk_right: movder := true;
    vk_up: movarr := true;
    vk_down: movAba := true;
    vk_space: naveDisparar;
  end;
end;


procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key of
    vk_left: movIzq := false;
    vk_right: movder := false;
    vk_up: movarr := false;
    vk_down: movAba := false;
  end;
end;

{Sirve para poner a la nave en posicion cuando el formulario se ajusta}
procedure TForm1.FormResize(Sender: TObject);
begin
  if nave<>nil then begin
     nave.y:=height - 150;
  end;
end;


{Logica para la animacion de las imagenes de los aliens}
procedure TForm1.Timer1Timer(Sender: TObject);
var i:byte;
begin
    for i := 1 to na do begin
      if alienA[i] <> nil then begin
          alienA[i].img.Visible:=not alienA[i].img.Visible;
          alienB[i].img.Visible:=not alienB[i].img.Visible;
      end;
    end;
end;




{Logica para mover a los aliens}
procedure TForm1.Timer2Timer(Sender: TObject);
var i, ini, fin:byte;
    dActual,dNueva:TDireccion;
begin
    ini := 0;
    fin := 0;

    {si no hay ninguno disponible}
    if cn = na then exit;


    {encontrar el primer disponible}
    for i := 1 to na do begin
      if alienA[i] <> nil then begin
         ini := i;
         break;
      end;
    end;

    {encontrar el ultimo disponible}
    for i := na downto 1 do begin
      if alienA[i] <> nil then begin
         fin := i;
         break;
      end;
    end;

    dActual:=alienA[ini].Direccion;
    dNueva:=dActual;

    {Verificar choque derecho}
    if (dActual=dDer) and (alienA[fin].x+alienA[fin].tamaño>= width-120) then dNueva:=dIzq;

    {Verificar choque izquierdo}
    if (dActual=dIzq) and (alienA[ini].x<=100) then dNueva:=dDer;

    if dActual=dNueva then begin
      for i := 1 to na do begin
        if alienA[i] = nil then continue;
        alienA[i].Mover;
        alienB[i].Mover;
      end;
    end else begin //si hay rebote
      for i := 1 to na do begin
        if alienA[i] = nil then continue;
        alienA[i].Direccion:=dNueva;
        alienB[i].Direccion:=dNueva;


        {Logica para que bajen al chocar}          ///////////////////añadido //


        alienA[i].y := alienA[i].y + 35;
        alienB[i].y := alienB[i].y + 35;

      end;
    end;

end;



{Lógica para hacer que los aliens disparen}
procedure TForm1.Timer3Timer(Sender: TObject);
var i:byte;
begin //control de los disparos del alien
   for i := 1 to na do begin
     if alienA[i] = nil then continue;
     if alienB[i].Tiempo>20 then begin
        alienB[i].Tiempo:=alienB[i].Tiempo-20;
     end else begin //disparar y reiniciar el contador
        alienB[i].Tiempo:=alienA[i].Tiempo;
        Disparar(alienA[i]);
     end;
   end;

   {movimiento de la nave}
    if movIzq and (nave.x > 20) then nave.Mover(dIzq);
    if movDer and (nave.x + nave.Ancho < Width) then nave.Mover(dDer);

      //  AGREGAR


   if movArr and (nave.y > 0) then nave.Mover(dArr);
    if movAba and (nave.y + nave.Alto < Height) then  nave.Mover(dAba);
end;


{Lógica para que las balas de los aliens funciones}
procedure TForm1.Timer4Timer(Sender: TObject);
var i,j:word;
begin //controla el movimiento de las balas
    j:=0;
    for i := 1 to nb do begin
        if balas[i]<>nil then begin//si hay bala en la posicion
           j:=j+1;
           if balas[i].y+10 > height then begin //si llega al limite inferior
              balas[i].Free;//muere la bala
              balas[i]:=nil;
           end else begin
              balas[i].Mover;
              if HuboImpacto(balas[i]) then begin//bala contra nave
                 timer4.Enabled:=false;
                 timer3.Enabled:=false;
                 timer2.Enabled:=false;
                 timer1.Enabled:=false;
                 nave.SetImagen('./explo.png');
                 MediaPlayer3.Play;
                 MediaPlayer1.Stop;
                 ShowMessage('(┬┬﹏┬┬)  G A M E   O V E R  (┬┬﹏┬┬)');
                 close;
              end;
           end;
        end;
    end;
    if j=0 then begin //si no hay balas volando
       timer4.Enabled:=false;
    end;
end;

//choque de las balas  de la nave a los aliends

procedure TForm1.Timer5Timer(Sender: TObject);
var i, j, k: word;
begin
  j := 0;
  for i := 1 to cantBalasNave do begin
    if balaNave[i]<>nil then begin
      j := j + 1;
      {preguntar si llego al limite}
      if balaNave[i].y + balaNave[i].GetAlto < 0 then begin
        balaNave[i].Free;
        balaNave[i] := nil;
      end else begin
        balaNave[i].Mover;
        {choque de las balas con los aliens}
        for k := 1 to na do begin
          if alienA[k] = nil then continue;
          if impactoNaveBala(balaNave[i], alienA[k]) then begin
            balaNave[i].img.Visible	:= false;
            balaNave[i].Free;
            balaNave[i] := nil;
            //destruir al bicho (alien)
            alienA[k].img.Visible := false;
            alienB[k].img.Visible	:= false;
            alienA[k].Free;
            alienB[k].Free;
            alienA[k] := nil;
            alienB[k] := nil;
            cn := cn + 1;
            MediaPlayer2.Play;
            break;
          end;
        end;
      end;
    end;
  end;
  if j=0 then begin //si no hay balas volando
    timer5.Enabled:=false;
  end;

  {logica de victoria}
  if cn = na then begin
    timer5.Enabled:=false;
    timer4.Enabled:=false;
    timer3.Enabled:=false;
    timer2.Enabled:=false;
    timer1.Enabled:=false;
    ShowMessage(' 💥   GANASTE QUE PRO   💥   (☞ ✪ 3 ✪)☞  ');

    close;

  end;
end;

function TForm1.PosicionLibre: Word;       //posicion de la bala de la nave
var p,i:word;
begin
   p:=0; i:=1;
   while i<=nb do begin
     if balas[i]=nil then  begin
       p:=i;
       i:=nb+1;
     end;
     i:=i+1;
   end;
   result:=p;
end;

procedure TForm1.Disparar(quien: TAlien);      //balas alien
var p:word;
begin //al disparar se crea una bala y se la pone en el container
  p:=PosicionLibre;
  balas[p]:=TBala.Create(Form1);
  balas[p].Direccion:=dAba;
  balas[p].x:=quien.x + quien.Tamaño div 2;
  balas[p].y:=quien.y + quien.Tamaño;
  balas[p].img.Stretch:=false;
  balas[p].img.AutoSize:=true;
  balas[p].SetImagen('./balaAlien.jpg');
  if not timer4.enabled then begin
    timer4.enabled:=true;
  end;
end;


function Tform1.HuboImpacto(quien:TBala):boolean;     //bala alien impacto nave
var x,y:word;
    hubo:boolean;
begin
   hubo:=false;
   for y := quien.y to quien.y+quien.Alto do begin
     for x:= quien.x to quien.x+quien.Ancho do begin
         if (x>=nave.x) and (x<=nave.x+nave.Ancho) and
            (y>=nave.y) and (y<=nave.y+nave.Alto) then begin
            hubo:=true;
         end;
     end;
   end;
   result:=hubo;
end;

function TForm1.impactoNaveBala(bala: TBala; alien: TAlien): boolean;    //bala nave impacto alien
begin
  result :=
    ((alien.GetX	+ alien.Tamaño) > bala.GetX) and
    ((alien.GetY + alien.Tamaño) > bala.GetY) and
    ((bala.GetAncho	 + bala.GetX)-1 > alien.GetX) and
    (( bala.GetAlto + bala.GetY)-1 > alien.GetY);
end;




procedure TForm1.naveDisparar;         //nave bota bala
var j, i: word;
begin
  i := 0;
  for j := 1 to cantBalasNave do begin
    if balaNave[j] = nil then begin
      i := j;
      break;
    end;
end;

  if i = 0 then exit;

  balaNave[i]:=TBala.Create(Form1);
  balaNave[i].Direccion:=dArr;
  balaNave[i].x:=nave.x + (nave.GetAncho div 2) - (balaNave[i].GetAncho div 2);
  balaNave[i].y:=nave.y;
  balaNave[i].img.Stretch:=false;
  balaNave[i].img.AutoSize:=true;
  balaNave[i].SetImagen('./balaNave.jpg');

  if not timer5.enabled then begin
    timer5.enabled:=true;
  end;
end;

end.
