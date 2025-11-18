import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  Color _gex) {
    final colors = [
      Colors.blu
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Copink,
      Colors.indigo,
    ];
    return colors[book.id.hashCode % colors.length];
  }

  @override
  Widget build(BuildContetext) {
    final bookColor = _getBookColor(0);
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectanr(
        borderRadius: BorderRar(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadiusar(16),
        child: Column(
          crossAxisAlignment: Crtch,
          children: [
            // Book cover with t
            Expanded(
              flex: 3,
              child:er(
                deion(
                  gradient: LinearGradient(
                    begin: Al.topLeft,
                    e
                    colors: [
                      bookColor.shade300,
                      bookColor.shade600,
                    ],
                  ),
                  borderRadius: const BorderRadiustical(
                  lar(16),
                  ),
                ),
                childtack(
                  children: [
                    // Decorative pattern
                    Positioned(
                      rit: -20,
                      top: -20,
                      child: Icon(
                  tories,
                        size: 100,
                        color: Coloty(0.1),
                      ),
                    ),
                    // Book icon
                    Center(
                      child: Ico(
                        Icons.menu_book_rounded,
                    
                  
                      ),
                ),
              ],
           ),
              ),
       ),
   
 (


  }
});,
     )   ),
     
             ],
         ), ),
                   ),
              
          ],         ),
                    ),
                     ],
                            ),
                  
           ),              
        okColor,olor: bo       c             
          0,tWeight.w60ght: FonontWei        f              ,
        ze: 12    fontSi                        xtStyle(
  : Telety s                      y',
     ngaọc 'Đ                       
     t(      Tex                 4),
    dth:izedBox(wi Sonst c                            ),
                      ookColor,
  bolor:          c                  : 16,
   size                  
       ow_rounded,ons.play_arrIc                           Icon(
                     [
       dren: chil                  ,
     ze.minxisSiinA Maze: mainAxisSi                       
child: Row(             ,
                    )     20),
      r(us.circula BorderRadis:Radiuer        bord        
        ity(0.1),ithOpacor.wlor: bookCol      co           (
       xDecorationation: Boecor        d             ),
                        6,
rtical:ve                       al: 12,
 rizont      ho               ic(
   mmetreInsets.syt Edg: consadding  p              r(
      aine      Cont            n
  Read butto      //          er(),
       const Spac                   ),
        
            ],                ),
                             ,
          )           
     sis,erflow.ellipflow: TextOv      over                     nes: 1,
 xLi  ma                    ),
                                   ariant,
   e.onSurfaceV.colorSchemext)me.of(contr: The        colo                      yWith(
    l?.copdySmalextTheme.bo(context).te: Theme.of       styl                     thor,
.auok      bo                (
       Texthild:       c          
         nded(       Expa           4),
      Box(width: nst Sized      co                 ),
                       ant,
  faceVariScheme.onSurolorcontext).c: Theme.of(orol   c               ,
        ze: 14         si             ne,
    person_outli Icons.                       n(
      Ico                   
 ildren: [  ch             (
        Row                 k author
    // Boo                t: 4),
  ox(heighizedBconst S             
                 ),       
   .ellipsis,verflowxtOrflow: Te     ove              2,
    axLines:      m              
        ),            ,
        .2 1     height:                       ,
oldht.bntWeigtWeight: Foon      f                 (
     yWith?.copeSmallxtTheme.titl.text)eme.of(contestyle: Th                   tle,
    book.ti                   t(
          Tex          ok title
  Bo     //      
          en: [ldr    chi            
  ent.start,ssAxisAlignmnt: CroAlignmeisrossAx  c          n(
      Colum:  child        ),
       2.0l(1Insets.alnst Edgecoding:  pad       (
        ngdihild: Pad    c      2,
       flex:            