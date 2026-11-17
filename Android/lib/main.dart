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
 const SpoolArt({super.key,this.size=100}); final double size;
 @override Widget build(BuildContext context)=>SizedBox(width:size,height:size,child:CustomPaint(painter:_SpoolPainter()));
}
class _SpoolPainter extends CustomPainter {
 @override void paint(Canvas c,Size s){
  c.save();c.scale(s.width/100,s.height/100);
  final glow=Paint()..color=const Color(0x442DD4BF)..maskFilter=const MaskFilter.blur(BlurStyle.normal,13);
  c.drawOval(const Rect.fromLTWH(16,9,70,86),glow);
  c.drawOval(const Rect.fromLTWH(8,12,72,78),Paint()..color=const Color(0xff102B3C));
  final filament=Paint()..color=const Color(0xff04D8C5)..style=PaintingStyle.stroke..strokeWidth=2.3;
  for(var x=19.0;x<55;x+=3.5){c.drawArc(Rect.fromLTWH(x,16,34,68),-1.7,3.45,false,filament);}
  c.drawOval(const Rect.fromLTWH(43,8,47,84),Paint()..color=const Color(0xff243D4B));
  c.drawOval(const Rect.fromLTWH(43,8,47,84),Paint()..color=const Color(0xff4E6A78)..style=PaintingStyle.stroke..strokeWidth=3);
  for(var i=0;i<6;i++){final a=i*1.0472;c.save();c.translate(66.5,50);c.rotate(a);c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4,-34,8,26),const Radius.circular(3)),Paint()..color=const Color(0xff0A1B2B));c.restore();}
  c.drawOval(const Rect.fromLTWH(55,36,23,28),Paint()..color=const Color(0xff0A1B2B));
  c.drawOval(const Rect.fromLTWH(61,42,11,16),Paint()..color=const Color(0xff506A7A));
  c.restore();
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class PrinterArt extends StatelessWidget{
 const PrinterArt({super.key});
 @override Widget build(BuildContext context)=>CustomPaint(size:const Size(145,130),painter:_PrinterPainter());
}
class _PrinterPainter extends CustomPainter{
 @override void paint(Canvas c,Size s){
  c.save();c.scale(s.width/145,s.height/130);
  final line=Paint()..color=const Color(0xff17D9CF)..style=PaintingStyle.stroke..strokeWidth=4..strokeCap=StrokeCap.round;
  final dark=Paint()..color=const Color(0xff125A70);
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15,9,115,8),const Radius.circular(3)),dark);
  c.drawLine(const Offset(24,15),const Offset(24,108),line);
  c.drawLine(const Offset(119,15),const Offset(119,108),line);
  c.drawLine(const Offset(17,107),const Offset(129,107),line);
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50,26,60,17),const Radius.circular(4)),Paint()..color=const Color(0xff128E9E));
  c.drawLine(const Offset(79,43),const Offset(79,54),line);
  c.drawPath(Path()..moveTo(71,54)..lineTo(87,54)..lineTo(80,63)..close(),Paint()..color=const Color(0xff2DD4BF));
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30,92,84,9),const Radius.circular(4)),Paint()..color=const Color(0xff14949C));
  final boat=Path()..moveTo(43,78)..lineTo(102,78)..lineTo(92,90)..lineTo(56,90)..close();
  c.drawPath(boat,Paint()..color=const Color(0xff20D5C6));
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(65,61,27,18),const Radius.circular(4)),Paint()..color=const Color(0xff1C9DAB));
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(73,50,12,15),const Radius.circular(3)),Paint()..color=const Color(0xff1DE1D0));
  c.drawCircle(const Offset(80,70),3,Paint()..color=const Color(0xff0B3947));
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
 List<Filament> filaments=[]; List<ExtraCost> packaging=[],postProcessing=[]; String? selected; int tab=0; int extraTab=0; bool excelExpanded=false; bool english=false; double? material,kwh,electric,total; final markup=TextEditingController(text:'30'); bool includeExtras=true; bool useMargin=false;
 String tr(String it,String en)=>english?en:it;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();try{filaments=(jsonDecode(p.getString('filaments')??'[]') as List).map((x)=>Filament(x['name'] as String,(x['price'] as num).toDouble())).toList();}catch(_){filaments=[];}energy.text=p.getString('energy')??'0,15';power.text=p.getString('power')??'200';english=p.getBool('english')??false;if(filaments.isNotEmpty)selected=filaments.first.name;try {packaging=(jsonDecode(p.getString('packaging_v11')??'[]') as List).map((x)=>ExtraCost(x['name'] as String,(x['price'] as num).toDouble(),enabled:x['enabled']!=false)).toList();postProcessing=(jsonDecode(p.getString('post_v11')??'[]') as List).map((x)=>ExtraCost(x['name'] as String,(x['price'] as num).toDouble(),enabled:x['enabled']!=false)).toList();}catch(_){packaging=[];postProcessing=[];}markup.text=p.getString('markup_v11')??'30';includeExtras=p.getBool('include_v11')??true;useMargin=p.getBool('margin_v11')??false;if(mounted)setState((){});}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('filaments',jsonEncode(filaments.map((f)=>{'name':f.name,'price':f.price}).toList()));await p.setString('energy',energy.text);await p.setString('power',power.text);await p.setBool('english',english);await p.setString('packaging_v11',jsonEncode(packaging.map((x)=>x.toJson()).toList()));await p.setString('post_v11',jsonEncode(postProcessing.map((x)=>x.toJson()).toList()));await p.setString('markup_v11',markup.text);await p.setBool('include_v11',includeExtras);await p.setBool('margin_v11',useMargin);}
 void msg(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
 Widget field(String title,TextEditingController c)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:title,filled:true,fillColor:const Color(0xff202F46),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xff54708A))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xff53677F)))));
 Widget card(String title,Widget child,{IconData icon=Icons.layers_outlined})=>Container(margin:const EdgeInsets.only(bottom:16),padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff172E45),Color(0xff151C36)]),borderRadius:BorderRadius.circular(24),border:Border.all(color:const Color(0xff29576B),width:1.2),boxShadow:const [BoxShadow(color:Color(0x44000000),blurRadius:16,offset:Offset(0,8))]),child:Stack(children:[if(icon==Icons.print_outlined)Positioned(right:-14,top:-20,child:Opacity(opacity:0.24,child:const PrinterArt())),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:teal,size:25),const SizedBox(width:10),Expanded(child:Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800)))]),const SizedBox(height:18),child])]));
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
 Widget calculator()=>ListView(padding:const EdgeInsets.fromLTRB(14,10,14,26),children:[
 card(tr('Dati della stampa','Print details'),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text(tr('Filamento','Filament'),style:const TextStyle(fontWeight:FontWeight.w700,fontSize:14)),
 const SizedBox(height:5),
 DropdownButtonFormField<String>(value:selected,decoration:InputDecoration(prefixIcon:const Icon(Icons.cable_outlined,color:teal),contentPadding:const EdgeInsets.symmetric(vertical:13,horizontal:12),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))),items:filaments.map((f)=>DropdownMenuItem(value:f.name,child:Text(f.name))).toList(),onChanged:(v)=>setState(()=>selected=v)),
 const SizedBox(height:12),field(tr('Filamento totale (g)','Total filament (g)'),grams),const SizedBox(height:12),
 Row(children:[Expanded(child:field(tr('Ore','Hours'),hours)),const SizedBox(width:12),Expanded(child:field(tr('Minuti','Minutes'),minutes))]),
 const SizedBox(height:16),btn(tr('CALCOLA COSTO','CALCULATE COST'),calculate)]),icon:Icons.print_outlined),
 card(tr('Costi di produzione','Production costs'),Column(children:[detailLine(tr('Filamento','Filament'),material),detailLine(tr('Energia elettrica','Electricity'),electric),const Divider(),detailLine(tr('Totale produzione','Production total'),total,prominent:true)]),icon:Icons.precision_manufacturing_outlined),
 card(tr('Spese di imballaggio','Packaging costs'),Column(children:[detailLine(tr('Voci attive','Enabled items'),packingTotal),TextButton.icon(onPressed:()=>setState((){tab=2;extraTab=0;}),icon:const Icon(Icons.edit_outlined),label:Text(tr('Gestisci imballaggio','Manage packaging')))]),icon:Icons.inventory_2_outlined),
 card(tr('Post-produzione','Post-processing'),Column(children:[detailLine(tr('Voci attive','Enabled items'),postTotal),TextButton.icon(onPressed:()=>setState((){tab=2;extraTab=1;}),icon:const Icon(Icons.edit_outlined),label:Text(tr('Gestisci post-produzione','Manage post-processing')))]),icon:Icons.brush_outlined),
 card(tr('Prezzo di vendita','Selling price'),Column(children:[
 SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(tr('Includi imballaggio e post-produzione','Include packaging and post-processing')),value:includeExtras,onChanged:(v){setState(()=>includeExtras=v);save();}),
 SegmentedButton<bool>(segments:[ButtonSegment(value:false,label:Text(tr('Ricarico','Markup'))),ButtonSegment(value:true,label:Text(tr('Margine','Margin')))],selected:{useMargin},onSelectionChanged:(v){setState(()=>useMargin=v.first);save();}),
 const SizedBox(height:12),TextField(controller:markup,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:tr('Percentuale (%)','Percentage (%)'),suffixText:'%',border:const OutlineInputBorder()),onChanged:(_){setState((){});save();}),
 const SizedBox(height:10),Text(tr('Ricarico: percentuale sul costo. Margine: percentuale sul prezzo finale.','Markup: percentage of cost. Margin: percentage of final selling price.'),style:const TextStyle(color:Colors.white60,fontSize:12)),
 ]),icon:Icons.sell_outlined),
 card(tr('Riepilogo completo','Full summary'),Column(children:[
 detailLine(tr('Produzione','Production'),total),detailLine(tr('Imballaggio','Packaging'),packingTotal),detailLine(tr('Post-produzione','Post-processing'),postTotal),
 const Divider(),detailLine(tr('Costo complessivo','Total cost'),completeCost,prominent:true),
 detailLine(tr('Guadagno stimato','Estimated profit'),salePrice==null||completeCost==null?null:salePrice!-completeCost!),
 const SizedBox(height:8),Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff007F80),Color(0xff5936BB)]),borderRadius:BorderRadius.circular(15)),child:Column(children:[Text(tr('PREZZO DI VENDITA CONSIGLIATO','SUGGESTED SELLING PRICE'),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:5),Text(salePrice==null?'—':euro(salePrice!),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900))])),
 ]),icon:Icons.auto_graph_outlined),
 card(tr('Riepilogo','Summary'),Column(children:[
 Container(padding:const EdgeInsets.symmetric(vertical:14,horizontal:5),decoration:BoxDecoration(color:const Color(0xff20314D),borderRadius:BorderRadius.circular(17)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
 metric(tr('Costo filamento','Filament cost'),material==null?'—':euro(material!),Icons.layers_outlined),
 Container(height:75,width:1,color:const Color(0xff54637B)),
 metric(tr('Energia stimata','Estimated energy'),kwh==null?'—':'${kwh!.toStringAsFixed(3)} kWh',Icons.bolt),
 Container(height:75,width:1,color:const Color(0xff54637B)),
 metric(tr('Costo corrente','Electricity cost'),electric==null?'—':euro(electric!),Icons.power_outlined)])),
 const SizedBox(height:12),Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:12,vertical:18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff063E49),Color(0xff08575A)]),borderRadius:BorderRadius.circular(17),border:Border.all(color:teal,width:1.5)),child:Row(children:[const Icon(Icons.monetization_on,color:Color(0xffFCD34D),size:27),const SizedBox(width:8),Expanded(child:Text(tr('COSTO TOTALE','TOTAL COST'),style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800))),FittedBox(child:Text(total==null?'—':euro(total!),style:const TextStyle(fontSize:27,color:teal,fontWeight:FontWeight.w900)))]))]),icon:Icons.bar_chart_rounded),
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
 appBar:AppBar(toolbarHeight:105,backgroundColor:bg,title:Row(children:[const Icon(Icons.print_outlined,color:teal,size:37),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('3D Print Cost v1.1',style:TextStyle(fontWeight:FontWeight.w900,fontSize:23)),Text(tr('Calcola il costo delle tue stampe 3D','Calculate your 3D printing costs'),style:const TextStyle(fontSize:12,color:Color(0xffA8BDCD)))])),const SpoolArt(size:66),const SizedBox(width:2),const Icon(Icons.info_outline,color:Color(0xffA8BDCD),size:19)]),bottom:PreferredSize(preferredSize:const Size.fromHeight(3),child:Container(height:3,decoration:const BoxDecoration(gradient:LinearGradient(colors:[teal,blue,Color(0xff9A48EB)]))))),
 body:Column(children:[
 Container(height:79,padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),child:Row(children:[
 for(final (i,icon,label) in [(0,Icons.calculate_outlined,tr('Calcolo','Calculator')),(1,Icons.layers_outlined,tr('Filamenti','Filaments')),(2,Icons.category_outlined,tr('Voci','Items')),(3,Icons.settings_outlined,tr('Impostazioni','Settings'))])
 Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:2),child:InkWell(onTap:()=>setState(()=>tab=i),borderRadius:BorderRadius.circular(17),child:Container(decoration:BoxDecoration(gradient:tab==i?const LinearGradient(colors:[Color(0xff057B77),Color(0xff094F5A)]):null,color:tab==i?null:const Color(0xff152338),borderRadius:BorderRadius.circular(17),border:Border.all(color:tab==i?teal:const Color(0xff34455C),width:tab==i?2:1)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:tab==i?Colors.white:const Color(0xffCFDBE6),size:24),const SizedBox(height:3),FittedBox(child:Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)))])))))])),
 Expanded(child:[calculator(),filamentPage(),extraPage(),settings()][tab])
 ])));
}
