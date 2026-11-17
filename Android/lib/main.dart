import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';

const bg=Color(0xff0B1120),panel=Color(0xff151E2E),teal=Color(0xff2DD4BF),blue=Color(0xff38BDF8);
void main()=>runApp(const MaterialApp(debugShowCheckedModeBanner:false,home:CostApp()));
double? parse(String v)=>double.tryParse(v.trim().replaceAll(',','.'));
String euro(double n)=>'€ ${n.toStringAsFixed(2).replaceAll('.',',')}';
// Decorative artwork drawn natively: no network images or external assets.
class SpoolArt extends StatelessWidget {
 const SpoolArt({super.key,this.size=110}); final double size;
 @override Widget build(BuildContext context)=>SizedBox(width:size,height:size,child:CustomPaint(painter:_SpoolPainter()));
}
class _SpoolPainter extends CustomPainter {
 @override void paint(Canvas c,Size size){
  c.save();c.scale(size.width/120,size.height/120);
  final halo=Paint()..color=const Color(0x8834D8D1)..maskFilter=const MaskFilter.blur(BlurStyle.normal,19);
  c.drawOval(const Rect.fromLTWH(22,12,88,99),halo);
  final purple=Paint()..color=const Color(0x777F4FFF)..maskFilter=const MaskFilter.blur(BlurStyle.normal,12);
  c.drawOval(const Rect.fromLTWH(58,7,50,104),purple);
  // Filament trail flowing out of the spool.
  final trail=Path()..moveTo(29,88)..cubicTo(6,83,7,109,0,114);
  c.drawPath(trail,Paint()..color=const Color(0xff24EBD7)..style=PaintingStyle.stroke..strokeWidth=2.5..strokeCap=StrokeCap.round);
  c.drawPath(trail,Paint()..color=const Color(0x8824EBD7)..style=PaintingStyle.stroke..strokeWidth=7..maskFilter=const MaskFilter.blur(BlurStyle.normal,5));
  // Rear elliptical flange, with a luminous purple edge.
  final back=Rect.fromLTWH(53,10,58,98);
  c.drawOval(back,Paint()..shader=const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff8A5AFF),Color(0xff21335B),Color(0xff0C1831)]).createShader(back));
  c.drawOval(back,Paint()..color=const Color(0xffAF74FF)..style=PaintingStyle.stroke..strokeWidth=2.5);
  // Wound filament: curved cylindrical body, visible at a 3/4 angle.
  final body=Path()..moveTo(36,20)..cubicTo(54,12,78,23,83,45)..lineTo(83,78)..cubicTo(75,100,55,105,34,94)..cubicTo(20,79,20,39,36,20)..close();
  c.drawPath(body,Paint()..shader=const LinearGradient(colors:[Color(0xff035D75),Color(0xff17E7D2),Color(0xff06A5C7),Color(0xff062E55)],stops:[0,0.34,0.66,1]).createShader(const Rect.fromLTWH(23,15,65,90)));
  c.save();c.clipPath(body);
  for(var i=0;i<25;i++){
   final x=23.0+i*2.6;
   c.drawArc(Rect.fromLTWH(x,19,33,76),-1.62,3.35,false,Paint()..color=i.isEven?const Color(0xff6CFFF0):const Color(0xff058DAB)..style=PaintingStyle.stroke..strokeWidth=1.45);
  }
  c.restore();
  // Front flange, shaded as a thick three-dimensional circular rim.
  final rim=Rect.fromLTWH(50,14,52,94);
  c.drawOval(rim,Paint()..shader=const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff708DA1),Color(0xff233C56),Color(0xff09172B),Color(0xff4C6B86)]).createShader(rim));
  c.drawOval(rim,Paint()..color=const Color(0xffA5D6E7)..style=PaintingStyle.stroke..strokeWidth=2.4);
  c.drawOval(const Rect.fromLTWH(57,21,38,80),Paint()..color=const Color(0xff10283D));
  c.drawOval(const Rect.fromLTWH(57,21,38,80),Paint()..color=const Color(0xff35546A)..style=PaintingStyle.stroke..strokeWidth=1.5);
  // Radial spokes with highlights.
  for(var i=0;i<6;i++){
   c.save();c.translate(76,61);c.rotate(i*1.04719755);
   c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-3.2,-35,6.4,27),const Radius.circular(2)),Paint()..color=const Color(0xff4D7189));
   c.drawLine(const Offset(-2,-32),const Offset(-2,-12),Paint()..color=const Color(0xff94B9C6)..strokeWidth=1);
   c.restore();
  }
  c.drawOval(const Rect.fromLTWH(65,47,22,28),Paint()..color=const Color(0xff061526));
  c.drawOval(const Rect.fromLTWH(70,52,12,18),Paint()..color=const Color(0xff62889B));
  c.drawOval(const Rect.fromLTWH(73,55,6,12),Paint()..color=const Color(0xff0B1A2C));
  c.restore();
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class PrinterArt extends StatelessWidget {
 const PrinterArt({super.key,this.width=175});final double width;
 @override Widget build(BuildContext context)=>SizedBox(width:width,height:width*0.9,child:CustomPaint(painter:_PrinterPainter()));
}
class _PrinterPainter extends CustomPainter {
 @override void paint(Canvas c,Size size){
 c.save();c.scale(size.width/180,size.height/162);
 Paint p(int hex)=>Paint()..color=Color(hex);
 Paint stroke(int hex,double w)=>Paint()..color=Color(hex)..style=PaintingStyle.stroke..strokeWidth=w..strokeJoin=StrokeJoin.round;
 Path polygon(List<Offset> points){final path=Path()..moveTo(points.first.dx,points.first.dy);for(final q in points.skip(1)){path.lineTo(q.dx,q.dy);}return path..close();}
 c.drawOval(const Rect.fromLTWH(30,38,125,110),Paint()..color=const Color(0x774C3DFF)..maskFilter=const MaskFilter.blur(BlurStyle.normal,22));
 c.drawOval(const Rect.fromLTWH(35,50,110,80),Paint()..color=const Color(0x6635EDE4)..maskFilter=const MaskFilter.blur(BlurStyle.normal,16));
 // Three-dimensional chassis and LCD panel.
 final base=polygon([const Offset(12,129),const Offset(137,129),const Offset(172,144),const Offset(44,155)]);
 c.drawPath(base,p(0xff23365C));c.drawPath(base,stroke(0xff7E77EA,1.7));
 c.drawPath(polygon([const Offset(44,155),const Offset(172,144),const Offset(172,155),const Offset(44,162)]),p(0xff111C36));
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(134,142,27,13),const Radius.circular(2)),p(0xff0A1527));
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(138,145,19,8),const Radius.circular(1)),p(0xff12DCD7));
 // Illuminated build plate.
 final bed=polygon([const Offset(31,111),const Offset(123,108),const Offset(150,121),const Offset(59,131)]);
 c.drawPath(bed,p(0xff173C60));c.drawPath(bed,stroke(0xff44E9F3,2));
 // Printed purple Benchy, with cabin and windows.
 final hull=polygon([const Offset(59,104),const Offset(122,103),const Offset(109,120),const Offset(74,121)]);
 c.drawPath(hull,Paint()..shader=const LinearGradient(colors:[Color(0xff34DBF6),Color(0xffA54CFA),Color(0xff5B32D0)]).createShader(const Rect.fromLTWH(59,102,63,19)));
 c.drawPath(hull,stroke(0xffE6B3FF,1.4));
 c.drawPath(polygon([const Offset(82,82),const Offset(109,82),const Offset(108,104),const Offset(83,105)]),p(0xff8851F2));
 c.drawPath(polygon([const Offset(87,73),const Offset(105,73),const Offset(109,82),const Offset(82,82)]),p(0xffBC7FFF));
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(87,86,11,11),const Radius.circular(2)),p(0xff132A4B));
 c.drawRect(const Rect.fromLTWH(92,67,4,6),p(0xffDAB5FF));
 c.drawCircle(const Offset(76,111),2.5,p(0xffE4B9FF));
 // Gantry rails and upper frame.
 for(final x in [19.0,148.0]){c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,16,11,116),const Radius.circular(2)),p(0xff111A2E));c.drawRect(Rect.fromLTWH(x+2,21,3,104),p(0xff708AA6));c.drawLine(Offset(x+9,22),Offset(x+9,124),stroke(0xff18DDE6,1.6));}
 c.drawPath(polygon([const Offset(17,15),const Offset(150,15),const Offset(160,26),const Offset(27,26)]),p(0xff485A7C));
 c.drawPath(polygon([const Offset(27,26),const Offset(160,26),const Offset(160,35),const Offset(27,35)]),p(0xff0A172B));
 c.drawLine(const Offset(30,28),const Offset(151,28),stroke(0xff50E6F3,2));
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(28,49,126,7),const Radius.circular(3)),p(0xff566A8B));
 // Printhead, cooling fan and hot nozzle.
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(74,39,43,29),const Radius.circular(5)),p(0xff111B34));
 c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(79,43,33,21),const Radius.circular(4)),p(0xff38517A));
 c.drawCircle(const Offset(95,53),8,p(0xff0B1A30));
 for(var i=0;i<5;i++){c.save();c.translate(95,53);c.rotate(i*1.256637);c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-1.4,-7,3,6),const Radius.circular(1)),p(0xff59C9DF));c.restore();}
 c.drawPath(polygon([const Offset(90,68),const Offset(100,68),const Offset(97,74),const Offset(93,74)]),p(0xffA9C8DC));
 c.drawLine(const Offset(95,74),const Offset(95,79),stroke(0xff29FFF1,2));
 c.drawCircle(const Offset(95,79),8,Paint()..color=const Color(0x9924F6E6)..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));
 // Mounted filament spool.
 c.drawOval(const Rect.fromLTWH(132,3,23,29),p(0xff182344));c.drawOval(const Rect.fromLTWH(135,6,17,23),stroke(0xffB18AFF,2));c.drawOval(const Rect.fromLTWH(140,12,8,12),p(0xff21D5E4));
 c.restore();
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class ExtraCost { ExtraCost(this.name,this.price,{this.enabled=true}); String name; double price; bool enabled; Map<String,dynamic> toJson()=>{'name':name,'price':price,'enabled':enabled}; }

// Decorative neon packaging illustration, painted as scalable vector shapes.
class PackagingArt extends StatelessWidget {
 const PackagingArt({super.key});
 @override Widget build(BuildContext context)=>SizedBox(height:190,child:CustomPaint(size:const Size(double.infinity,190),painter:_PackagingPainter()));
}
class _PackagingPainter extends CustomPainter {
 @override void paint(Canvas canvas,Size size){
  final c=canvas; c.save();c.translate(size.width/2-90,8);
  final glow=Paint()..color=const Color(0x4438BDF8)..maskFilter=const MaskFilter.blur(BlurStyle.normal,22);
  c.drawOval(const Rect.fromLTWH(12,64,180,100),glow);
  final left=Path()..moveTo(10,65)..lineTo(90,90)..lineTo(90,169)..lineTo(10,138)..close();
  final right=Path()..moveTo(90,90)..lineTo(174,61)..lineTo(174,140)..lineTo(90,169)..close();
  c.drawPath(left,Paint()..shader=const LinearGradient(colors:[Color(0xff05465B),Color(0xff0D7694)]).createShader(const Rect.fromLTWH(10,65,80,105)));
  c.drawPath(right,Paint()..shader=const LinearGradient(colors:[Color(0xff22246B),Color(0xff672CB1)]).createShader(const Rect.fromLTWH(90,61,85,110)));
  final stroke=Paint()..color=const Color(0xff25D8E8)..strokeWidth=2..style=PaintingStyle.stroke;
  c.drawPath(left,stroke);c.drawPath(right,stroke);
  for(var i=0;i<12;i++){final x=45.0+(i%4)*21,y=57.0+(i~/4)*10;c.drawCircle(Offset(x,y),7,Paint()..color=const Color(0xff29B8C8)..style=PaintingStyle.stroke..strokeWidth=2);}
  final flapL=Path()..moveTo(10,65)..lineTo(90,90)..lineTo(65,48)..lineTo(-12,28)..close();
  final flapR=Path()..moveTo(90,90)..lineTo(174,61)..lineTo(198,29)..lineTo(112,49)..close();
  c.drawPath(flapL,Paint()..color=const Color(0xff0B516C));c.drawPath(flapL,stroke);
  c.drawPath(flapR,Paint()..color=const Color(0xff292777));c.drawPath(flapR,Paint()..color=const Color(0xff9B64FF)..style=PaintingStyle.stroke..strokeWidth=2);
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(99,35,36,43),const Radius.circular(8)),Paint()..color=const Color(0xff0A293D));
  for(var i=0;i<5;i++){c.drawArc(Rect.fromLTWH(102+i*3,36,25,39),-1.7,3.2,false,Paint()..color=const Color(0xff22D3EE)..style=PaintingStyle.stroke..strokeWidth=1.5);}
  c.restore();
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class Filament {Filament(this.name,this.price); String name; double price;}
class CostApp extends StatefulWidget {const CostApp({super.key}); @override State<CostApp> createState()=>_CostState();}
class _CostState extends State<CostApp>{
 final grams=TextEditingController(),hours=TextEditingController(text:'0'),minutes=TextEditingController(text:'0'),energy=TextEditingController(text:'0,15'),power=TextEditingController(text:'200');
 List<Filament> filaments=[]; List<ExtraCost> packaging=[],postProcessing=[]; String? selected; int tab=0; int extraTab=0; bool excelExpanded=false; bool english=false; final Set<int> expandedSections={4}; double? material,kwh,electric,total; final markup=TextEditingController(text:'30'); bool includeExtras=true; bool useMargin=false;
 String tr(String it,String en)=>english?en:it;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();try{filaments=(jsonDecode(p.getString('filaments')??'[]') as List).map((x)=>Filament(x['name'] as String,(x['price'] as num).toDouble())).toList();}catch(_){filaments=[];}energy.text=p.getString('energy')??'0,15';power.text=p.getString('power')??'200';english=p.getBool('english')??false;if(filaments.isNotEmpty)selected=filaments.first.name;try {packaging=(jsonDecode(p.getString('packaging_v11')??'[]') as List).map((x)=>ExtraCost(x['name'] as String,(x['price'] as num).toDouble(),enabled:x['enabled']!=false)).toList();postProcessing=(jsonDecode(p.getString('post_v11')??'[]') as List).map((x)=>ExtraCost(x['name'] as String,(x['price'] as num).toDouble(),enabled:x['enabled']!=false)).toList();}catch(_){packaging=[];postProcessing=[];}markup.text=p.getString('markup_v11')??'30';includeExtras=p.getBool('include_v11')??true;useMargin=p.getBool('margin_v11')??false;if(mounted)setState((){});}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('filaments',jsonEncode(filaments.map((f)=>{'name':f.name,'price':f.price}).toList()));await p.setString('energy',energy.text);await p.setString('power',power.text);await p.setBool('english',english);await p.setString('packaging_v11',jsonEncode(packaging.map((x)=>x.toJson()).toList()));await p.setString('post_v11',jsonEncode(postProcessing.map((x)=>x.toJson()).toList()));await p.setString('markup_v11',markup.text);await p.setBool('include_v11',includeExtras);await p.setBool('margin_v11',useMargin);}
 void msg(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
 Widget field(String title,TextEditingController c)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:title,filled:true,fillColor:const Color(0xff202F46),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xff54708A))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xff53677F)))));
 Widget card(String title,Widget child,{IconData icon=Icons.layers_outlined})=>Container(margin:const EdgeInsets.only(bottom:16),padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff172E45),Color(0xff151C36)]),borderRadius:BorderRadius.circular(24),border:Border.all(color:const Color(0xff29576B),width:1.2),boxShadow:const [BoxShadow(color:Color(0x44000000),blurRadius:16,offset:Offset(0,8))]),child:Stack(children:[if(icon==Icons.print_outlined)Positioned(right:0,top:0,child:Opacity(opacity:0.94,child:const PrinterArt(width:150))),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:teal,size:25),const SizedBox(width:10),Expanded(child:Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800)))]),const SizedBox(height:18),child])]));
 Widget btn(String title,VoidCallback fn,{IconData icon=Icons.calculate_outlined})=>SizedBox(width:double.infinity,child:Container(decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff16D6BD),Color(0xff3187D4),Color(0xff9645E8)]),borderRadius:BorderRadius.circular(28)),child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:Colors.transparent,shadowColor:Colors.transparent,foregroundColor:Colors.white,padding:const EdgeInsets.symmetric(vertical:16)),onPressed:fn,icon:Icon(icon),label:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)))));
 Widget metric(String label,String value,IconData icon)=>Expanded(child:Column(children:[Icon(icon,color:teal,size:23),const SizedBox(height:7),Text(label,textAlign:TextAlign.center,style:const TextStyle(fontSize:11,color:Color(0xffC5D3E4))),const SizedBox(height:5),FittedBox(fit:BoxFit.scaleDown,child:Text(value,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)))]));
 void calculate(){final g=parse(grams.text),h=parse(hours.text),m=parse(minutes.text),e=parse(energy.text),w=parse(power.text);if(selected==null||[g,h,m,e,w].any((x)=>x==null||!x!.isFinite||x<0)||m!>=60){msg(tr('Controlla i dati e seleziona un filamento.','Check inputs and select a filament.'));return;}final f=filaments.firstWhere((x)=>x.name==selected);setState((){material=g!/1000*f.price;kwh=w!/1000*(h!+m!/60);electric=kwh!*e!;total=material!+electric!;});}
 Future<void> exportWithMode(bool append)async{if(total==null){msg(tr('Calcola prima il costo.','Calculate cost first.'));return;}try{
 xl.Excel book; if(append){final pick=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx'],withData:true);if(pick==null)return;final bytes=pick.files.single.bytes??await File(pick.files.single.path!).readAsBytes();book=xl.Excel.decodeBytes(bytes);}else{book=xl.Excel.createExcel();}
 final name=english?'Print summary':'Riepilogo stampa';final sheet=book.sheets[name]??book[book.getDefaultSheet()??'Sheet1'];
 final heads=['Plate','Date/Time','Filament','Total filament (g)','Filament price (€/kg)','Print hours','Average power (W)','Estimated energy (kWh)','Electricity price (€/kWh)','Filament cost (€)','Electricity cost (€)','Total plate cost (€)'];
 if(sheet.maxRows==0){sheet.appendRow(heads.map((v)=>xl.TextCellValue(v)).toList());}
 final f=filaments.firstWhere((x)=>x.name==selected);final count=sheet.maxRows;sheet.appendRow([xl.IntCellValue(count),xl.TextCellValue(DateTime.now().toIso8601String()),xl.TextCellValue(f.name),xl.DoubleCellValue(parse(grams.text)!),xl.DoubleCellValue(f.price),xl.DoubleCellValue(parse(hours.text)!+parse(minutes.text)!/60),xl.DoubleCellValue(parse(power.text)!),xl.DoubleCellValue(kwh!),xl.DoubleCellValue(parse(energy.text)!),xl.DoubleCellValue(material!),xl.DoubleCellValue(electric!),xl.DoubleCellValue(total!)]);
 final extraSheet=book.sheets['Additional costs']??book['Additional costs'];
 extraSheet.appendRow([xl.TextCellValue('Date/Time'),xl.TextCellValue('Packaging (€)'),xl.TextCellValue('Post-processing (€)'),xl.TextCellValue('Total cost (€)'),xl.TextCellValue('Selling price (€)'),xl.TextCellValue(useMargin?'Margin (%)':'Markup (%)')]);
 extraSheet.appendRow([xl.TextCellValue(DateTime.now().toIso8601String()),xl.DoubleCellValue(packingTotal),xl.DoubleCellValue(postTotal),xl.DoubleCellValue(completeCost??0),xl.DoubleCellValue(salePrice??0),xl.DoubleCellValue(parse(markup.text)??0)]);
 final bytes=book.encode();if(bytes==null)throw Exception('Excel encoding');
 final target=await FilePicker.platform.saveFile(
   dialogTitle:tr('Scegli dove salvare il file Excel','Choose where to save the Excel file'),
   fileName:append?'3d_print_cost_aggiornato.xlsx':'3d_print_cost_summary.xlsx',
   type:FileType.custom,allowedExtensions:['xlsx'],
   bytes:Uint8List.fromList(bytes));
 if(target!=null&&mounted)msg(tr('File Excel salvato.','Excel file saved.'));
 }catch(e){msg('Excel: $e');}}
 Future<void> editFilament([Filament? f])async{final name=TextEditingController(text:f?.name??''),price=TextEditingController(text:f?.price.toString()??'');await showDialog(context:context,builder:(c)=>AlertDialog(title:Text(f==null?tr('Nuovo filamento','New filament'):tr('Modifica filamento','Edit filament')),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Nome / Name')),const SizedBox(height:12),field('€/kg',price)]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),TextButton(onPressed:(){final p=parse(price.text),n=name.text.trim();if(n.isEmpty||p==null||!p.isFinite||p<0||filaments.any((x)=>x.name.toLowerCase()==n.toLowerCase()&&x!=f)){msg(tr('Nome o prezzo non valido','Invalid name or price'));return;}setState((){if(f==null){filaments.add(Filament(n,p));selected??=n;}else{if(selected==f.name)selected=n;f.name=n;f.price=p;}filaments.sort((a,b)=>a.name.toLowerCase().compareTo(b.name.toLowerCase()));total=null;});save();Navigator.pop(c);},child:Text(tr('Salva','Save')))]));}
 double sumExtras(List<ExtraCost> xs)=>xs.where((x)=>x.enabled).fold(0.0,(a,x)=>a+x.price);
 double get packingTotal=>includeExtras?sumExtras(packaging):0;
 double get postTotal=>includeExtras?sumExtras(postProcessing):0;
 double? get completeCost=>total==null?null:total!+packingTotal+postTotal;
 double? get salePrice {final c=completeCost,p=parse(markup.text);if(c==null||p==null||!p.isFinite||p<0||(useMargin&&p>=100))return null;return useMargin?c/(1-p/100):c*(1+p/100);}
 Widget detailLine(String name,double? value,{bool prominent=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[Expanded(child:Text(name,style:TextStyle(fontSize:prominent?15:13,fontWeight:prominent?FontWeight.bold:FontWeight.normal))),Text(value==null?'—':euro(value),style:TextStyle(color:prominent?teal:Colors.white,fontSize:prominent?19:14,fontWeight:FontWeight.w700))]));
 Future<void> editExtra(List<ExtraCost> items,[ExtraCost? existing])async{
 final name=TextEditingController(text:existing?.name??''),price=TextEditingController(text:existing?.price.toStringAsFixed(2)??'');
 await showDialog(context:context,builder:(ctx)=>AlertDialog(title:Text(existing==null?tr('Aggiungi voce','Add item'):tr('Modifica voce','Edit item')),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:InputDecoration(labelText:tr('Descrizione','Description'))),const SizedBox(height:12),field(tr('Costo (€)','Cost (€)'),price)]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(tr('Annulla','Cancel'))),FilledButton(onPressed:(){final n=name.text.trim(),v=parse(price.text);if(n.isEmpty||v==null||!v.isFinite||v<0){msg(tr('Inserisci nome e costo validi','Enter valid name and cost'));return;}setState((){if(existing==null){items.add(ExtraCost(n,v));}else{existing.name=n;existing.price=v;}});save();Navigator.pop(ctx);},child:Text(tr('Salva','Save')))]));
 name.dispose();price.dispose();
 }
 Future<void> removeExtra(List<ExtraCost> items,ExtraCost item)async{final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text(tr('Eliminare questa voce?','Delete this item?')),content:Text(item.name),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:Text(tr('Annulla','Cancel'))),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:Text(tr('Elimina','Delete')))]));if(yes==true){setState(()=>items.remove(item));save();}}
 Widget extrasSection(String title,List<ExtraCost> items,IconData icon)=>card(title,Column(children:[
  for(final item in items)Row(children:[Checkbox(value:item.enabled,onChanged:(v){setState(()=>item.enabled=v??true);save();}),Expanded(child:Text(item.name,overflow:TextOverflow.ellipsis,style:TextStyle(color:item.enabled?Colors.white:Colors.white54))),Text(euro(item.price),style:const TextStyle(fontWeight:FontWeight.bold)),IconButton(tooltip:tr('Modifica','Edit'),onPressed:()=>editExtra(items,item),icon:const Icon(Icons.edit_outlined,size:19)),IconButton(tooltip:tr('Elimina','Delete'),onPressed:()=>removeExtra(items,item),icon:const Icon(Icons.delete_outline,color:Colors.redAccent,size:19))]),
  if(items.isEmpty)Padding(padding:const EdgeInsets.all(12),child:Text(tr('Nessuna voce: aggiungine una qui sotto.','No items yet. Add one below.'),style:const TextStyle(color:Colors.white70))),
  const SizedBox(height:6),OutlinedButton.icon(onPressed:()=>editExtra(items),icon:const Icon(Icons.add),label:Text(tr('Aggiungi voce','Add item'))),
  const Divider(),detailLine(tr('Totale selezionato','Selected total'),sumExtras(items),prominent:true)
 ]),icon:icon);
 Widget extraPage()=>ListView(padding:const EdgeInsets.fromLTRB(14,12,14,24),children:[
  SegmentedButton<int>(segments:[ButtonSegment(value:0,label:Text(tr('Imballaggio','Packaging')),icon:const Icon(Icons.inventory_2_outlined)),ButtonSegment(value:1,label:Text(tr('Post-produzione','Post-processing')),icon:const Icon(Icons.brush_outlined))],selected:{extraTab},onSelectionChanged:(v)=>setState(()=>extraTab=v.first)),
  const SizedBox(height:16),extrasSection(extraTab==0?tr('Voci di imballaggio','Packaging items'):tr('Voci post-produzione','Post-processing items'),extraTab==0?packaging:postProcessing,extraTab==0?Icons.inventory_2_outlined:Icons.brush_outlined),
  const PackagingArt(),const SizedBox(height:12),Text(tr('Le voci vengono salvate sul dispositivo. Puoi attivarle o disattivarle per il calcolo.','Items are saved on your device. Toggle them to include or exclude from calculations.'),textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60))
 ]);
 Widget accordion(int index,String title,String subtitle,IconData icon,Widget child){
 final open=expandedSections.contains(index);
 return Container(margin:const EdgeInsets.only(bottom:9),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff162E48),Color(0xff151D36)]),borderRadius:BorderRadius.circular(17),border:Border.all(color:open?teal:const Color(0xff2B6C83),width:1.2)),child:Column(children:[
 InkWell(borderRadius:BorderRadius.circular(17),onTap:()=>setState((){if(open){expandedSections.remove(index);}else{expandedSections.add(index);}}),child:Padding(padding:const EdgeInsets.symmetric(horizontal:13,vertical:12),child:Row(children:[Icon(icon,color:teal,size:26),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),const SizedBox(height:2),Text(subtitle,style:const TextStyle(fontSize:12,color:Color(0xffC4D3E6)))])),Icon(open?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded,color:Colors.white70,size:27)]))),
 if(open)Padding(padding:const EdgeInsets.fromLTRB(14,0,14,14),child:Column(children:[const Divider(color:Color(0xff31566D)),child]))
 ]));
 }
 Widget calculator()=>ListView(padding:const EdgeInsets.fromLTRB(14,10,14,26),children:[
 card(tr('Dati della stampa','Print details'),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 const SizedBox(height:118),
 Text(tr('Filamento','Filament'),style:const TextStyle(fontWeight:FontWeight.w700,fontSize:14)),
 const SizedBox(height:5),
 DropdownButtonFormField<String>(value:selected,decoration:InputDecoration(prefixIcon:const Icon(Icons.cable_outlined,color:teal),contentPadding:const EdgeInsets.symmetric(vertical:13,horizontal:12),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))),items:filaments.map((f)=>DropdownMenuItem(value:f.name,child:Text(f.name))).toList(),onChanged:(v)=>setState(()=>selected=v)),
 const SizedBox(height:12),field(tr('Filamento totale (g)','Total filament (g)'),grams),const SizedBox(height:12),
 Row(children:[Expanded(child:field(tr('Ore','Hours'),hours)),const SizedBox(width:12),Expanded(child:field(tr('Minuti','Minutes'),minutes))]),
 const SizedBox(height:16),btn(tr('CALCOLA COSTO','CALCULATE COST'),calculate)]),icon:Icons.print_outlined),
 accordion(0,tr('Costi di produzione','Production costs'),total==null?tr('Filamento + energia','Filament + energy'):euro(total!),Icons.precision_manufacturing_outlined,Column(children:[detailLine(tr('Filamento','Filament'),material),detailLine(tr('Energia elettrica','Electricity'),electric),const Divider(),detailLine(tr('Totale produzione','Production total'),total,prominent:true) ])),
 accordion(1,tr('Spese di imballaggio','Packaging costs'),euro(packingTotal),Icons.inventory_2_outlined,Column(children:[detailLine(tr('Voci attive','Enabled items'),packingTotal),TextButton.icon(onPressed:()=>setState((){tab=2;extraTab=0;}),icon:const Icon(Icons.edit_outlined),label:Text(tr('Gestisci imballaggio','Manage packaging'))) ])),
 accordion(2,tr('Post-produzione','Post-processing'),euro(postTotal),Icons.brush_outlined,Column(children:[detailLine(tr('Voci attive','Enabled items'),postTotal),TextButton.icon(onPressed:()=>setState((){tab=2;extraTab=1;}),icon:const Icon(Icons.edit_outlined),label:Text(tr('Gestisci post-produzione','Manage post-processing'))) ])),
 accordion(3,tr('Prezzo di vendita','Selling price'),tr('Ricarico o margine','Markup or margin'),Icons.sell_outlined,Column(children:[
 SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(tr('Includi imballaggio e post-produzione','Include packaging and post-processing')),value:includeExtras,onChanged:(v){setState(()=>includeExtras=v);save();}),
 SegmentedButton<bool>(segments:[ButtonSegment(value:false,label:Text(tr('Ricarico','Markup'))),ButtonSegment(value:true,label:Text(tr('Margine','Margin')))],selected:{useMargin},onSelectionChanged:(v){setState(()=>useMargin=v.first);save();}),
 const SizedBox(height:12),TextField(controller:markup,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:tr('Percentuale (%)','Percentage (%)'),suffixText:'%',border:const OutlineInputBorder()),onChanged:(_){setState((){});save();}),
 const SizedBox(height:10),Text(tr('Ricarico: percentuale sul costo. Margine: percentuale sul prezzo finale.','Markup: percentage of cost. Margin: percentage of final selling price.'),style:const TextStyle(color:Colors.white60,fontSize:12)),
  ])),
 accordion(4,tr('Riepilogo completo','Full summary'),completeCost==null?'—':euro(completeCost!),Icons.auto_graph_outlined,Column(children:[
 detailLine(tr('Produzione','Production'),total),detailLine(tr('Imballaggio','Packaging'),packingTotal),detailLine(tr('Post-produzione','Post-processing'),postTotal),
 const Divider(),detailLine(tr('Costo complessivo','Total cost'),completeCost,prominent:true),
 detailLine(tr('Guadagno stimato','Estimated profit'),salePrice==null||completeCost==null?null:salePrice!-completeCost!),
 const SizedBox(height:8),Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff007F80),Color(0xff5936BB)]),borderRadius:BorderRadius.circular(15)),child:Column(children:[Text(tr('PREZZO DI VENDITA CONSIGLIATO','SUGGESTED SELLING PRICE'),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:5),Text(salePrice==null?'—':euro(salePrice!),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900))])),
  ])),
 Container(decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff05BFAF),Color(0xff3E8CD4),Color(0xff923DE0)]),borderRadius:BorderRadius.circular(25)),padding:const EdgeInsets.all(2),child:Column(children:[
 InkWell(onTap:()=>setState(()=>excelExpanded=!excelExpanded),child:Padding(padding:const EdgeInsets.symmetric(vertical:14,horizontal:14),child:Row(children:[const Icon(Icons.description_outlined,color:Colors.white),const SizedBox(width:10),Expanded(child:Text(tr('SALVA / ESPORTA EXCEL','SAVE / EXPORT EXCEL'),style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15))),Icon(excelExpanded?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down)]))),
 if(excelExpanded)Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:4),decoration:BoxDecoration(color:const Color(0xff1B2D46),borderRadius:BorderRadius.circular(22)),child:Column(children:[
 ListTile(leading:const Icon(Icons.note_add_outlined),title:Text(tr('Nuovo file Excel (scegli dove salvare)','New Excel file (choose location)')),trailing:const Icon(Icons.chevron_right),onTap:()=>exportWithMode(false)),
 const Divider(height:1),ListTile(leading:const Icon(Icons.edit_document),title:Text(tr('Aggiungi a file esistente','Append to existing file')),trailing:const Icon(Icons.chevron_right),onTap:()=>exportWithMode(true))]))])),
 const SizedBox(height:22)
 ]);
 Widget filamentPage()=>ListView(padding:const EdgeInsets.all(16),children:[btn(tr('AGGIUNGI FILAMENTO','ADD FILAMENT'),()=>editFilament()),...filaments.map((f)=>Card(color:panel,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),child:ListTile(leading:const Icon(Icons.view_in_ar,color:teal),title:Text(f.name),subtitle:Text('${euro(f.price)}/kg'),onTap:()=>editFilament(f),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text(tr('Eliminare filamento?','Delete filament?')),content:Text(f.name),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('No')),TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Yes'))]));if(yes==true){setState((){filaments.remove(f);if(selected==f.name)selected=filaments.isEmpty?null:filaments.first.name;total=null;});save();}}))))]); 
 Widget settings()=>ListView(padding:const EdgeInsets.all(16),children:[card(tr('IMPOSTAZIONI','SETTINGS'),Column(children:[field(tr('Costo corrente (€/kWh)','Electricity price (€/kWh)'),energy),const SizedBox(height:14),field(tr('Consumo medio stampante (W)','Average printer power (W)'),power),const SizedBox(height:14),SwitchListTile(title:const Text('English'),value:english,onChanged:(v){setState(()=>english=v);save();}),btn(tr('SALVA IMPOSTAZIONI','SAVE SETTINGS'),(){final e=parse(energy.text),w=parse(power.text);if(e==null||w==null||!e.isFinite||!w.isFinite||e<0||w<0){msg(tr('Valori non validi','Invalid values'));return;}save();setState(()=>total=null);msg(tr('Impostazioni salvate','Settings saved'));})]))]);
 @override Widget build(BuildContext context)=>Theme(data:ThemeData(useMaterial3:true,brightness:Brightness.dark,scaffoldBackgroundColor:bg,colorScheme:ColorScheme.fromSeed(seedColor:teal,brightness:Brightness.dark)),child:Scaffold(
 appBar:AppBar(toolbarHeight:120,backgroundColor:bg,titleSpacing:12,title:Stack(clipBehavior:Clip.none,children:[Positioned(right:0,top:-19,child:IgnorePointer(child:Opacity(opacity:0.98,child:const SpoolArt(size:112)))),Padding(padding:const EdgeInsets.only(top:8,bottom:7,right:86),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.print_outlined,color:teal,size:29),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('3D Print Cost',maxLines:1,style:TextStyle(fontWeight:FontWeight.w900,fontSize:23,letterSpacing:-0.6)),const Text('v1.1',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:Color(0xffB678FF))),const SizedBox(height:3),Text(tr('Calcola costi e prezzo di vendita delle tue stampe 3D','Calculate costs and selling prices for your 3D prints'),maxLines:2,style:const TextStyle(fontSize:11,color:Color(0xffC1D2E5),height:1.2))]))]))]),bottom:PreferredSize(preferredSize:const Size.fromHeight(3),child:Container(height:3,decoration:const BoxDecoration(gradient:LinearGradient(colors:[teal,blue,Color(0xff9A48EB)]))))),
 body:Column(children:[
 Container(height:79,padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),child:Row(children:[
 for(final (i,icon,label) in [(0,Icons.calculate_outlined,tr('Calcolo','Calculator')),(1,Icons.layers_outlined,tr('Filamenti','Filaments')),(2,Icons.category_outlined,tr('Voci','Items')),(3,Icons.settings_outlined,tr('Impostazioni','Settings'))])
 Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:2),child:InkWell(onTap:()=>setState(()=>tab=i),borderRadius:BorderRadius.circular(17),child:Container(decoration:BoxDecoration(gradient:tab==i?const LinearGradient(colors:[Color(0xff057B77),Color(0xff094F5A)]):null,color:tab==i?null:const Color(0xff152338),borderRadius:BorderRadius.circular(17),border:Border.all(color:tab==i?teal:const Color(0xff34455C),width:tab==i?2:1)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:tab==i?Colors.white:const Color(0xffCFDBE6),size:24),const SizedBox(height:3),FittedBox(child:Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)))])))))])),
 Expanded(child:[calculator(),filamentPage(),extraPage(),settings()][tab])
 ])));
}
