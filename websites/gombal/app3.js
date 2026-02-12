// === GOMBAL TALK V3 — Final Evolution ===

const G=[
{id:1,indo:"Kamu tahu kenapa aku suka hujan? Karena setiap tetes air mengingatkanku pada senyummu yang menyegarkan hariku.",en:"You know why I love rain? Because every drop reminds me of your smile that refreshes my day.",cat:"romantic"},
{id:2,indo:"Kalau kamu bintang, aku rela jadi langit malam supaya bisa selalu memelukmu.",en:"If you were a star, I'd gladly be the night sky so I could always hold you.",cat:"romantic"},
{id:3,indo:"Matamu lebih indah dari seribu matahari terbenam.",en:"Your eyes are more beautiful than a thousand sunsets.",cat:"romantic"},
{id:4,indo:"Aku nggak butuh Google Maps, karena aku sudah menemukan jalan ke hatimu.",en:"I don't need Google Maps, because I've already found the way to your heart.",cat:"romantic"},
{id:5,indo:"Dulu aku nggak percaya cinta pandangan pertama, sampai aku melihatmu.",en:"I never believed in love at first sight, until I saw you.",cat:"romantic"},
{id:6,indo:"Kalau cinta itu dosa, aku rela jadi pendosa paling besar untukmu.",en:"If love is a sin, I'd gladly be the biggest sinner for you.",cat:"romantic"},
{id:7,indo:"Kamu adalah alasan kenapa aku percaya bahwa malaikat itu nyata.",en:"You're the reason I believe angels are real.",cat:"romantic"},
{id:8,indo:"Setiap detik tanpamu terasa seperti seabad, tapi setiap detik bersamamu terasa terlalu singkat.",en:"Every second without you feels like a century, but every second with you feels too short.",cat:"romantic"},
{id:9,indo:"Kamu capek nggak? Soalnya kamu berlari di pikiranku seharian.",en:"Are you tired? Because you've been running through my mind all day.",cat:"cheesy"},
{id:10,indo:"Bapakmu pencuri ya? Karena dia mencuri semua bintang dan menaruhnya di matamu.",en:"Is your dad a thief? Because he stole all the stars and put them in your eyes.",cat:"cheesy"},
{id:11,indo:"Kamu punya peta nggak? Karena aku tersesat di matamu.",en:"Do you have a map? Because I'm lost in your eyes.",cat:"cheesy"},
{id:12,indo:"Nama kamu WiFi ya? Soalnya aku ngerasa ada connection.",en:"Is your name WiFi? Because I feel a connection.",cat:"cheesy"},
{id:13,indo:"Kamu magnet ya? Karena aku selalu tertarik ke kamu.",en:"Are you a magnet? Because I'm always attracted to you.",cat:"cheesy"},
{id:14,indo:"Jangan dekat-dekat, nanti aku bisa diabetes. Soalnya kamu terlalu manis.",en:"Don't come too close, I might get diabetes. Because you're too sweet.",cat:"cheesy"},
{id:15,indo:"Kamu tukang parkir ya? Karena kamu berhasil memarkirkan hatiku.",en:"Are you a parking attendant? Because you've successfully parked my heart.",cat:"cheesy"},
{id:16,indo:"Kamu anak kedokteran ya? Soalnya setiap liat kamu, jantungku berdetak lebih cepat.",en:"Are you a med student? Because every time I see you, my heart beats faster.",cat:"cheesy"},
{id:17,indo:"Aku bukan fotografer, tapi aku bisa membayangkan kita bersama.",en:"I'm not a photographer, but I can picture us together.",cat:"funny"},
{id:18,indo:"Hidup tanpa kamu kayak nasi goreng tanpa kecap. Bisa sih, tapi nggak ada rasanya.",en:"Life without you is like nasi goreng without kecap. Possible, but tasteless.",cat:"funny"},
{id:19,indo:"Kamu virus ya? Karena kamu sudah menginfeksi hatiku.",en:"Are you a virus? Because you've infected my heart.",cat:"funny"},
{id:20,indo:"Aku bukan ahli matematika, tapi aku yakin kita itu jodoh. Karena kamu itu separuh aku.",en:"I'm not a mathematician, but I'm sure we're soulmates. Because you're my other half.",cat:"funny"},
{id:21,indo:"Kalau kamu jadi sayur, kamu pasti jadi brokoli. Soalnya kamu bro paling koli di hidupku.",en:"If you were a vegetable, you'd be a broccoli. Because you're the 'bro' coolest in my life.",cat:"funny"},
{id:22,indo:"Aku bukan Superman, tapi aku bisa terbang kalau ada kamu di sampingku.",en:"I'm not Superman, but I can fly when you're beside me.",cat:"funny"},
{id:23,indo:"Kamu surat tilang ya? Karena kamu bikin aku berhenti mendadak.",en:"Are you a traffic ticket? Because you made me stop suddenly.",cat:"funny"},
{id:24,indo:"Aku mau jadi sandal kamu, biar aku yang kamu injak-injak tapi tetap setia.",en:"I want to be your sandal, so you can step on me but I'll stay loyal.",cat:"funny"},
{id:25,indo:"Maaf, boleh pinjam handphonemu? Aku mau telepon surga, bilang malaikatnya sudah lepas.",en:"Sorry, can I borrow your phone? I need to call heaven and tell them an angel escaped.",cat:"smooth"},
{id:26,indo:"Kalau keindahan itu waktu, kamu pasti keabadian.",en:"If beauty were time, you'd be eternity.",cat:"smooth"},
{id:27,indo:"Kamu bukan cuma cantik, kamu itu karya seni yang bikin museum cemburu.",en:"You're not just beautiful, you're a work of art that makes museums jealous.",cat:"smooth"},
{id:28,indo:"Senyummu itu obat paling ampuh yang pernah aku temukan.",en:"Your smile is the most powerful medicine I've ever found.",cat:"smooth"},
{id:29,indo:"Aku nggak butuh kompas, karena arah hidupku sudah menuju ke kamu.",en:"I don't need a compass, because my life's direction already points to you.",cat:"smooth"},
{id:30,indo:"Kalau tatapanmu bisa dijual, pasti harganya nggak terbilang.",en:"If your gaze could be sold, it would be priceless.",cat:"smooth"},
{id:31,indo:"Dunia ini berhenti berputar setiap kali kamu tersenyum.",en:"The world stops spinning every time you smile.",cat:"smooth"},
{id:32,indo:"Kamu satu-satunya alasan WiFi hatiku selalu terkoneksi.",en:"You're the only reason the WiFi of my heart stays connected.",cat:"smooth"},
{id:33,indo:"Aku mau jadi selimut kamu, biar aku yang hangatkan kamu setiap malam.",en:"I want to be your blanket, so I can keep you warm every night.",cat:"sweet"},
{id:34,indo:"Kalau setiap senyummu jadi bintang, langit nggak akan cukup menampungnya.",en:"If every smile of yours became a star, the sky wouldn't be big enough to hold them.",cat:"sweet"},
{id:35,indo:"Aku nggak minta banyak. Cukup kamu, kopi, dan pagi yang tenang.",en:"I don't ask for much. Just you, coffee, and a quiet morning.",cat:"sweet"},
{id:36,indo:"Kamu tahu kenapa langit mendung? Karena semua keindahannya pindah ke matamu.",en:"You know why the sky is cloudy? Because all its beauty moved to your eyes.",cat:"sweet"},
{id:37,indo:"Seandainya aku bisa memilih mimpi, aku akan memilih mimpi yang ada kamu di dalamnya.",en:"If I could choose my dreams, I'd choose the ones with you in them.",cat:"sweet"},
{id:38,indo:"Aku rela begadang semalaman, asal yang menemaniku adalah suara tawamu.",en:"I'd gladly stay up all night, as long as your laughter keeps me company.",cat:"sweet"},
{id:39,indo:"Kalau rindu punya bentuk, pasti bentuknya kamu.",en:"If longing had a shape, it would look like you.",cat:"sweet"},
{id:40,indo:"Cinta itu rumit, tapi bersamamu semuanya jadi sederhana.",en:"Love is complicated, but with you everything becomes simple.",cat:"sweet"},
];

let filter='all',cur=G[0],favs=JSON.parse(localStorage.getItem('gt-fav')||'[]'),seen=new Set();

document.addEventListener('DOMContentLoaded',()=>{
    initCanvas();initMobile();initReveal();renderBrowse();renderSaved();
});

// === Generate ===
function generateGombal(){
    const card=document.getElementById('mainCard');
    const pool=filter==='all'?G:G.filter(g=>g.cat===filter);
    if(!pool.length)return;
    let next;
    do{next=pool[Math.floor(Math.random()*pool.length)]}
    while(pool.length>1&&next.id===cur.id);
    cur=next;seen.add(cur.id);
    document.getElementById('seenCount').textContent=seen.size;

    card.classList.add('switching');
    setTimeout(()=>{
        const names={romantic:'Romantic',cheesy:'Cheesy',funny:'Funny',smooth:'Smooth',sweet:'Sweet'};
        document.getElementById('cardCat').textContent=names[cur.cat];
        document.getElementById('cardQuote').textContent=cur.indo;
        document.getElementById('cardTrans').textContent=cur.en;
        document.getElementById('cardId').textContent=`#${cur.id} of ${G.length}`;
        updateFavBtn();
        card.classList.remove('switching');
    },280);
}

// === Filter ===
function setFilter(cat,btn){
    filter=cat;
    document.querySelectorAll('.pill').forEach(p=>{p.classList.remove('active');p.setAttribute('aria-selected','false')});
    btn.classList.add('active');btn.setAttribute('aria-selected','true');
    generateGombal();
}

// === Copy / Share ===
function copyGombal(){
    const t=`${cur.indo}\n\n(${cur.en})\n\n— GombalTalk`;
    navigator.clipboard.writeText(t).then(()=>snack('Copied!')).catch(()=>{
        const a=document.createElement('textarea');a.value=t;document.body.appendChild(a);a.select();document.execCommand('copy');document.body.removeChild(a);snack('Copied!');
    });
}
function shareGombal(){
    const t=`${cur.indo}\n\n(${cur.en})\n\n— GombalTalk`;
    if(navigator.share)navigator.share({title:'GombalTalk',text:t,url:location.href}).catch(()=>{});
    else copyGombal();
}

// === Favourites ===
function toggleFav(){
    const i=favs.indexOf(cur.id);
    if(i>-1)favs.splice(i,1);else favs.push(cur.id);
    localStorage.setItem('gt-fav',JSON.stringify(favs));
    updateFavBtn();renderSaved();
}
function updateFavBtn(){
    const b=document.getElementById('favBtn'),f=favs.includes(cur.id);
    b.classList.toggle('active',f);
    b.innerHTML=f
        ?'<svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>'
        :'<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>';
}
function removeFav(id){
    favs=favs.filter(f=>f!==id);
    localStorage.setItem('gt-fav',JSON.stringify(favs));
    updateFavBtn();renderSaved();
}
function renderSaved(){
    const el=document.getElementById('savedList'),sub=document.getElementById('savedSub');
    if(!favs.length){el.innerHTML='<p class="saved-empty">Tap the bookmark icon to save favourites here.</p>';sub.textContent='Bookmark your favourites — they\'re stored locally';return}
    sub.textContent=`${favs.length} saved`;
    el.innerHTML=favs.map(id=>{
        const g=G.find(l=>l.id===id);if(!g)return'';
        return`<div class="saved-card"><span class="saved-card-text">${g.indo}</span><button class="saved-card-rm" onclick="removeFav(${g.id})" aria-label="Remove"><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button></div>`;
    }).join('');
}

// === Browse ===
let browseFilter='all';
function setBrowse(cat,btn){
    browseFilter=cat;
    document.querySelectorAll('.browse-tab').forEach(t=>t.classList.remove('active'));
    btn.classList.add('active');renderBrowse();
}
function renderBrowse(){
    const grid=document.getElementById('browseGrid');
    const pool=browseFilter==='all'?G:G.filter(g=>g.cat===browseFilter);
    const names={romantic:'Romantic',cheesy:'Cheesy',funny:'Funny',smooth:'Smooth',sweet:'Sweet'};
    grid.innerHTML=pool.map(g=>`
        <div class="browse-item" onclick="loadFromBrowse(${g.id})">
            <div class="browse-item-cat">${names[g.cat]}</div>
            <div class="browse-item-text">${g.indo}</div>
            <div class="browse-item-en">${g.en}</div>
        </div>
    `).join('');
}
function loadFromBrowse(id){
    cur=G.find(g=>g.id===id);seen.add(cur.id);
    document.getElementById('seenCount').textContent=seen.size;
    const names={romantic:'Romantic',cheesy:'Cheesy',funny:'Funny',smooth:'Smooth',sweet:'Sweet'};
    document.getElementById('cardCat').textContent=names[cur.cat];
    document.getElementById('cardQuote').textContent=cur.indo;
    document.getElementById('cardTrans').textContent=cur.en;
    document.getElementById('cardId').textContent=`#${cur.id} of ${G.length}`;
    updateFavBtn();
    document.getElementById('generator').scrollIntoView({behavior:'smooth'});
}

// === Snackbar ===
function snack(msg){
    const s=document.getElementById('snackbar');s.textContent=msg;
    s.classList.add('show');setTimeout(()=>s.classList.remove('show'),2000);
}

// === Canvas Background ===
function initCanvas(){
    const c=document.getElementById('bgCanvas'),ctx=c.getContext('2d');
    let w,h,dots=[];
    function resize(){w=c.width=innerWidth;h=c.height=innerHeight;dots=[];
        for(let i=0;i<40;i++)dots.push({x:Math.random()*w,y:Math.random()*h,r:Math.random()*1.5+0.5,vx:(Math.random()-.5)*.15,vy:(Math.random()-.5)*.15,o:Math.random()*.3+.05});
    }
    function draw(){
        ctx.clearRect(0,0,w,h);
        dots.forEach(d=>{
            d.x+=d.vx;d.y+=d.vy;
            if(d.x<0)d.x=w;if(d.x>w)d.x=0;if(d.y<0)d.y=h;if(d.y>h)d.y=0;
            ctx.beginPath();ctx.arc(d.x,d.y,d.r,0,Math.PI*2);
            ctx.fillStyle=`rgba(201,149,124,${d.o})`;ctx.fill();
        });
        requestAnimationFrame(draw);
    }
    resize();draw();window.addEventListener('resize',resize);
}

// === Mobile ===
function initMobile(){
    const btn=document.getElementById('navHamburger'),drawer=document.getElementById('mobileDrawer');
    btn.addEventListener('click',()=>{btn.classList.toggle('open');drawer.classList.toggle('open')});
    drawer.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{btn.classList.remove('open');drawer.classList.remove('open')}));
}

// === Scroll Reveal ===
function initReveal(){
    const obs=new IntersectionObserver(entries=>{
        entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('visible')});
    },{threshold:.15});
    document.querySelectorAll('[data-reveal]').forEach(el=>obs.observe(el));
}

// === Keyboard ===
document.addEventListener('keydown',e=>{
    if((e.code==='Space'||e.code==='Enter')&&!['BUTTON','A','INPUT'].includes(e.target.tagName)){
        e.preventDefault();generateGombal();
    }
});
