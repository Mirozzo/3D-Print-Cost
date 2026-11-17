"""Windows v1.1: editable packaging/post-processing expenses and selling-price calculator."""
import math
import sqlite3
import tkinter as tk
from tkinter import ttk, messagebox


TEXT = {
 "it": {
  "title":"Costi aggiuntivi e prezzo di vendita", "pack":"Spese di imballaggio",
  "post":"Post-produzione", "selling":"Prezzo di vendita", "name":"Descrizione",
  "cost":"Costo (€)", "active":"Attiva", "add":"Aggiungi", "edit":"Modifica",
  "delete":"Elimina", "clear":"Pulisci", "selected":"Seleziona una voce.",
  "invalid":"Inserisci una descrizione e un costo valido, non negativo.",
  "exists":"Esiste già una voce con questo nome nella categoria.",
  "confirm":"Eliminare la voce selezionata?", "production":"Costi di produzione",
  "pack_total":"Totale imballaggio", "post_total":"Totale post-produzione",
  "all_total":"Costo complessivo", "profit":"Guadagno stimato",
  "sale":"PREZZO DI VENDITA CONSIGLIATO", "include":"Includi spese aggiuntive",
  "markup":"Ricarico sul costo (%)", "margin":"Margine sul prezzo (%)",
  "percent":"Percentuale (%)", "hint":"Ricarico: percentuale sul costo. Margine: percentuale sul prezzo di vendita.",
  "no_calc":"Calcola prima il costo di stampa nella finestra principale.",
  "bad_percent":"La percentuale deve essere non negativa; il margine deve essere inferiore al 100%.",
  "saved":"Le modifiche vengono salvate automaticamente nel database locale.",
  "items":"Voci attive", "total":"Totale", "refresh":"Aggiorna riepilogo",
  "material":"Filamento", "electric":"Elettricità"
 },
 "en": {
  "title":"Additional costs and selling price", "pack":"Packaging costs",
  "post":"Post-processing", "selling":"Selling price", "name":"Description",
  "cost":"Cost (€)", "active":"Enabled", "add":"Add", "edit":"Edit",
  "delete":"Delete", "clear":"Clear", "selected":"Select an item.",
  "invalid":"Enter a description and a valid non-negative cost.",
  "exists":"An item with this name already exists in this category.",
  "confirm":"Delete the selected item?", "production":"Production costs",
  "pack_total":"Packaging total", "post_total":"Post-processing total",
  "all_total":"Total cost", "profit":"Estimated profit",
  "sale":"SUGGESTED SELLING PRICE", "include":"Include additional expenses",
  "markup":"Markup on cost (%)", "margin":"Margin on selling price (%)",
  "percent":"Percentage (%)", "hint":"Markup: percentage of cost. Margin: percentage of selling price.",
  "no_calc":"Calculate the print cost in the main window first.",
  "bad_percent":"Percentage must be non-negative; margin must be less than 100%.",
  "saved":"Changes are automatically saved to the local database.",
  "items":"Enabled items", "total":"Total", "refresh":"Refresh summary",
  "material":"Filament", "electric":"Electricity"
 }
}


def install_schema(db):
    db.conn.execute("""
        CREATE TABLE IF NOT EXISTS additional_costs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL CHECK(category IN ('packaging','post')),
            name TEXT NOT NULL COLLATE NOCASE,
            amount REAL NOT NULL CHECK(amount >= 0),
            enabled INTEGER NOT NULL DEFAULT 1 CHECK(enabled IN (0,1)),
            UNIQUE(category, name)
        )
    """)
    db.conn.commit()
    if db.get_setting("sales_percent") is None:
        db.set_setting("sales_percent", "30")
    if db.get_setting("sales_mode") is None:
        db.set_setting("sales_mode", "markup")
    if db.get_setting("include_extra_costs") is None:
        db.set_setting("include_extra_costs", "1")


def expense_rows(db, category):
    return db.conn.execute(
        "SELECT id,name,amount,enabled FROM additional_costs WHERE category=? ORDER BY name COLLATE NOCASE",
        (category,)
    ).fetchall()


def cost_snapshot(db, print_result):
    """Return a stable per-plate snapshot; does not alter the original production total."""
    production = float(print_result["total"]) if print_result else 0.0
    material = float(print_result["material_cost"]) if print_result else 0.0
    electricity = float(print_result["energy_cost"]) if print_result else 0.0
    included = db.get_setting("include_extra_costs") != "0"
    packaging = sum(float(row[2]) for row in expense_rows(db,"packaging") if row[3]) if included else 0.0
    post = sum(float(row[2]) for row in expense_rows(db,"post") if row[3]) if included else 0.0
    total = production + packaging + post
    mode = db.get_setting("sales_mode") or "markup"
    try:
        percent = float((db.get_setting("sales_percent") or "30").replace(",","."))
    except ValueError:
        percent = float("nan")
    valid = math.isfinite(percent) and percent >= 0 and (mode != "margin" or percent < 100)
    price = (total / (1-percent/100) if mode == "margin" else total*(1+percent/100)) if valid else None
    return {"material":material,"electricity":electricity,"production":production,
            "packaging":packaging,"post":post,"total":total,"mode":mode,
            "percent":percent if valid else None,"price":price,
            "profit":price-total if price is not None else None,
            "included":included,
            "packaging_items":sum(bool(r[3]) for r in expense_rows(db,"packaging")),
            "post_items":sum(bool(r[3]) for r in expense_rows(db,"post"))}


def add_excel_details(wb, db, result, plate_number, lang):
    """Append v1.1 data to a dedicated sheet, keeping legacy 12-column print sheets intact."""
    from openpyxl.styles import Font, PatternFill
    sheet = "Additional costs" if lang == "en" else "Costi aggiuntivi"
    ws = wb[sheet] if sheet in wb.sheetnames else wb.create_sheet(sheet)
    headers = (["Plate","Production (€)","Packaging (€)","Post-processing (€)",
                "Total cost (€)","Pricing mode","Percentage (%)","Selling price (€)","Estimated profit (€)"]
               if lang=="en" else
               ["Piatto","Produzione (€)","Imballaggio (€)","Post-produzione (€)",
                "Costo complessivo (€)","Modalità prezzo","Percentuale (%)","Prezzo vendita (€)","Guadagno stimato (€)"])
    if ws.max_row == 1 and ws["A1"].value is None:
        ws.append(headers)
        for cell in ws[1]:
            cell.font = Font(bold=True,color="FFFFFF")
            cell.fill = PatternFill("solid",fgColor="174D67")
    info = cost_snapshot(db,result)
    ws.append([plate_number,info["production"],info["packaging"],info["post"],
               info["total"],info["mode"],info["percent"],info["price"],info["profit"]])
    for col in "BCDEHI":
        ws[f"{col}{ws.max_row}"].number_format = '€ #,##0.00'
    for col in "ABCDEFGHI":
        ws.column_dimensions[col].width = 23
    ws.freeze_panes = "A2"


class CostsWindow(tk.Toplevel):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent=parent
        self.db=parent.db
        self.lang=parent.lang
        self.T=TEXT[self.lang]
        self.title("3D Print Cost v1.1 — "+self.T["title"])
        self.geometry("1100x790")
        self.minsize(850,610)
        self.configure(bg="#0B1120")
        try:
            self.iconbitmap(parent.iconbitmap())
        except (tk.TclError, TypeError):
            pass
        self.transient(parent)
        self.protocol("WM_DELETE_WINDOW",self.close)
        self.mode=tk.StringVar(value=self.db.get_setting("sales_mode") or "markup")
        self.percent=tk.StringVar(value=self.db.get_setting("sales_percent") or "30")
        self.include=tk.BooleanVar(value=self.db.get_setting("include_extra_costs")!="0")
        self.trees={}
        self.forms={}
        self.build()
        self.update_all()

    def close(self):
        self.parent.costs_window=None
        self.destroy()

    def label(self, container, text, **kwargs):
        return tk.Label(container,text=text,bg="#151E2E",**({"fg":"#F8FAFC","font":("Bahnschrift",11)} | kwargs))

    def build(self):
        head=tk.Frame(self,bg="#0B1120")
        head.pack(fill="x",padx=24,pady=(18,8))
        tk.Label(head,text="◈  3D PRINT COST   /   v1.1",bg="#0B1120",fg="#4DE8DA",font=("Bahnschrift SemiBold",14)).pack(anchor="w")
        tk.Label(head,text=self.T["title"],bg="#0B1120",fg="#F8FAFC",font=("Bahnschrift SemiBold",25)).pack(anchor="w",pady=(3,6))
        style=ttk.Style(self)
        style.configure("V11.TNotebook",background="#0B1120",borderwidth=0)
        style.configure("V11.TNotebook.Tab",padding=(23,13),font=("Bahnschrift SemiBold",11))
        style.configure("V11.Treeview",rowheight=35,font=("Bahnschrift",11))
        style.configure("V11.Treeview.Heading",font=("Bahnschrift SemiBold",11))
        self.tabs=ttk.Notebook(self,style="V11.TNotebook")
        self.tabs.pack(fill="both",expand=True,padx=22,pady=(6,12))
        for category,title in (("packaging",self.T["pack"]),("post",self.T["post"])):
            self.build_expenses(category,title)
        self.build_selling()

    def build_expenses(self, category, title):
        tab=tk.Frame(self.tabs,bg="#151E2E")
        self.tabs.add(tab,text=("  ▣  " if category=="packaging" else "  ✦  ")+title+"  ")
        self.label(tab,title,font=("Bahnschrift SemiBold",17)).pack(anchor="w",padx=20,pady=(16,10))
        tree=ttk.Treeview(tab,columns=("name","amount","enabled"),show="headings",height=10,style="V11.Treeview")
        for col,label in (("name",self.T["name"]),("amount",self.T["cost"]),("enabled",self.T["active"])):
            tree.heading(col,text=label)
        tree.column("name",width=470)
        tree.column("amount",width=150,anchor="center")
        tree.column("enabled",width=110,anchor="center")
        tree.pack(fill="both",expand=True,padx=20)
        tree.bind("<<TreeviewSelect>>",lambda _e,cat=category:self.load_selected(cat))
        form=tk.Frame(tab,bg="#151E2E")
        form.pack(fill="x",padx=20,pady=12)
        name=tk.StringVar()
        amount=tk.StringVar()
        enabled=tk.BooleanVar(value=True)
        self.label(form,self.T["name"]).grid(row=0,column=0,sticky="w")
        self.label(form,self.T["cost"]).grid(row=0,column=1,sticky="w",padx=10)
        ttk.Entry(form,textvariable=name,width=44).grid(row=1,column=0,sticky="ew",pady=5)
        ttk.Entry(form,textvariable=amount,width=18).grid(row=1,column=1,sticky="ew",padx=10,pady=5)
        ttk.Checkbutton(form,text=self.T["active"],variable=enabled).grid(row=1,column=2,sticky="w")
        form.columnconfigure(0,weight=1)
        buttons=tk.Frame(tab,bg="#151E2E")
        buttons.pack(fill="x",padx=20,pady=(0,12))
        for label,action in ((self.T["add"],lambda cat=category:self.save_item(cat,False)),
                             (self.T["edit"],lambda cat=category:self.save_item(cat,True)),
                             (self.T["delete"],lambda cat=category:self.delete_item(cat)),
                             (self.T["clear"],lambda cat=category:self.clear_form(cat))):
            ttk.Button(buttons,text=label,command=action).pack(side="left",padx=(0,9))
        total=self.label(tab,"")
        total.pack(anchor="e",padx=22,pady=(0,10))
        self.trees[category]=(tree,total)
        self.forms[category]=(name,amount,enabled)

    def _card(self, parent, title, accent="#36D7D1"):
        outer=tk.Frame(parent,bg="#263F61",padx=1,pady=1)
        inner=tk.Frame(outer,bg="#18283E",padx=17,pady=13)
        inner.pack(fill="both",expand=True)
        tk.Label(inner,text=title,bg="#18283E",fg=accent,font=("Bahnschrift SemiBold",14)).pack(anchor="w",pady=(0,11))
        return outer,inner

    def _line(self, parent, label, key, emphasized=False):
        row=tk.Frame(parent,bg="#18283E")
        row.pack(fill="x",pady=5)
        tk.Label(row,text=label,bg="#18283E",fg="#E1EAF6",font=("Bahnschrift SemiBold" if emphasized else "Bahnschrift",11)).pack(side="left")
        val=tk.Label(row,text="—",bg="#18283E",fg="#54E4D7" if emphasized else "#FFFFFF",font=("Bahnschrift SemiBold",16 if emphasized else 12))
        val.pack(side="right")
        self.result_labels[key]=val

    def build_selling(self):
        tab=tk.Frame(self.tabs,bg="#101A2B")
        self.tabs.add(tab,text="  ◈  "+self.T["selling"]+"  ")
        outer=tk.Frame(tab,bg="#101A2B")
        outer.pack(fill="both",expand=True,padx=18,pady=16)
        outer.grid_columnconfigure(0,weight=5)
        outer.grid_columnconfigure(1,weight=6)
        outer.grid_rowconfigure(0,weight=1)
        left=tk.Frame(outer,bg="#101A2B")
        left.grid(row=0,column=0,sticky="nsew",padx=(0,9))
        right=tk.Frame(outer,bg="#101A2B")
        right.grid(row=0,column=1,sticky="nsew",padx=(9,0))
        settings,config=self._card(left,"⚙  "+self.T["selling"])
        settings.pack(fill="x",pady=(0,12))
        ttk.Checkbutton(config,text=self.T["include"],variable=self.include,command=self.changed).pack(anchor="w",pady=(0,14))
        tk.Label(config,text=("MODALITÀ DI CALCOLO" if self.lang=="it" else "PRICING METHOD"),bg="#18283E",fg="#B6C7DB",font=("Bahnschrift SemiBold",10)).pack(anchor="w",pady=(0,7))
        switch=tk.Frame(config,bg="#18283E")
        switch.pack(fill="x",pady=(0,10))
        for label,value in ((self.T["markup"],"markup"),(self.T["margin"],"margin")):
            ttk.Radiobutton(switch,text=label,variable=self.mode,value=value,command=self.changed).pack(anchor="w",pady=5)
        tk.Label(config,text=self.T["percent"],bg="#18283E",fg="#F8FAFC",font=("Bahnschrift SemiBold",11)).pack(anchor="w",pady=(7,6))
        entry=ttk.Entry(config,textvariable=self.percent,width=15,font=("Bahnschrift SemiBold",17))
        entry.pack(anchor="w",ipady=5)
        entry.bind("<KeyRelease>",lambda _e:self.changed())
        tk.Label(config,text=self.T["hint"],bg="#18283E",fg="#B2C5D8",font=("Bahnschrift",10),wraplength=340,justify="left").pack(anchor="w",pady=(12,0))
        detail,detail_body=self._card(left,"▤  "+self.T["production"])
        detail.pack(fill="x")
        self.result_labels={}
        self._line(detail_body,self.T["material"],"material")
        self._line(detail_body,self.T["electric"],"electric")
        self._line(detail_body,self.T["production"],"production",True)
        summary,summary_body=self._card(right,"▤  "+("Riepilogo completo" if self.lang=="it" else "Full summary"))
        summary.pack(fill="x",pady=(0,12))
        self._line(summary_body,self.T["production"],"production_summary")
        self._line(summary_body,self.T["pack_total"],"pack_total")
        self._line(summary_body,self.T["post_total"],"post_total")
        tk.Frame(summary_body,bg="#355778",height=1).pack(fill="x",pady=8)
        self._line(summary_body,self.T["all_total"],"all_total",True)
        self._line(summary_body,self.T["profit"],"profit",True)
        banner=tk.Frame(right,bg="#2859A1",padx=2,pady=2)
        banner.pack(fill="x",pady=(0,12))
        banner_inner=tk.Frame(banner,bg="#174A80",padx=17,pady=20)
        banner_inner.pack(fill="both",expand=True)
        tk.Label(banner_inner,text="✦  "+self.T["sale"],bg="#174A80",fg="#C9FCF5",font=("Bahnschrift SemiBold",12)).pack(anchor="w")
        sale=tk.Label(banner_inner,text="—",bg="#174A80",fg="#FFFFFF",font=("Bahnschrift SemiBold",37))
        sale.pack(anchor="w",pady=(8,2))
        self.result_labels["sale"]=sale
        ttk.Button(right,text="↻  "+self.T["refresh"],command=self.update_all).pack(anchor="e",pady=6)

    def clear_form(self,category):
        name,amount,enabled=self.forms[category]
        name.set("");amount.set("");enabled.set(True)
        tree,_=self.trees[category]
        tree.selection_remove(tree.selection())

    def load_selected(self,category):
        tree,_=self.trees[category]
        selected=tree.selection()
        if selected:
            values=tree.item(selected[0],"values")
            name,amount,enabled=self.forms[category]
            name.set(values[0]);amount.set(str(values[1]).replace(".",","))
            enabled.set(values[2]=="✓")

    def save_item(self,category,edit):
        tree,_=self.trees[category]
        selected=tree.selection()
        if edit and not selected:
            messagebox.showinfo(self.T["title"],self.T["selected"],parent=self);return
        name,amount,enabled=self.forms[category]
        try:
            value=float(amount.get().strip().replace(",","."))
            if not name.get().strip() or not math.isfinite(value) or value<0:
                raise ValueError()
        except ValueError:
            messagebox.showerror(self.T["title"],self.T["invalid"],parent=self);return
        try:
            if edit:
                self.db.conn.execute("UPDATE additional_costs SET name=?,amount=?,enabled=? WHERE id=? AND category=?",
                                     (name.get().strip(),value,int(enabled.get()),int(selected[0]),category))
            else:
                self.db.conn.execute("INSERT INTO additional_costs(category,name,amount,enabled) VALUES(?,?,?,?)",
                                     (category,name.get().strip(),value,int(enabled.get())))
            self.db.conn.commit()
        except sqlite3.IntegrityError:
            messagebox.showerror(self.T["title"],self.T["exists"],parent=self);return
        self.clear_form(category)
        self.update_all()

    def delete_item(self,category):
        tree,_=self.trees[category]
        selected=tree.selection()
        if not selected:
            messagebox.showinfo(self.T["title"],self.T["selected"],parent=self);return
        if messagebox.askyesno(self.T["title"],self.T["confirm"],parent=self):
            self.db.conn.execute("DELETE FROM additional_costs WHERE id=? AND category=?",
                                 (int(selected[0]),category))
            self.db.conn.commit()
            self.clear_form(category)
            self.update_all()

    def changed(self):
        raw=self.percent.get().strip().replace(",",".")
        try:
            value=float(raw)
            if not math.isfinite(value) or value<0 or (self.mode.get()=="margin" and value>=100):
                raise ValueError()
        except ValueError:
            self.result_labels["sale"].config(text="—")
            self.result_labels["profit"].config(text="—")
            return
        self.db.set_setting("sales_percent",str(value))
        self.db.set_setting("sales_mode",self.mode.get())
        self.db.set_setting("include_extra_costs","1" if self.include.get() else "0")
        self.update_all()

    def update_all(self):
        for category in ("packaging","post"):
            tree,total=self.trees[category]
            for item in tree.get_children():tree.delete(item)
            rows=expense_rows(self.db,category)
            for item_id,name,amount,enabled in rows:
                tree.insert("","end",iid=str(item_id),values=(name,f"{amount:.2f}","✓" if enabled else "—"))
            total_value=sum(float(r[2]) for r in rows if r[3])
            total.config(text=f'{self.T["items"]}: {sum(bool(r[3]) for r in rows)}  |  {self.T["total"]}: € {total_value:.2f}')
        result=self.parent._last_result()
        info=cost_snapshot(self.db,result)
        if not result:
            for label in self.result_labels.values():label.config(text="—")
            return
        mapping={"material":info["material"],"electric":info["electricity"],"production":info["production"],"production_summary":info["production"],
                 "pack_total":info["packaging"],"post_total":info["post"],"all_total":info["total"],
                 "profit":info["profit"],"sale":info["price"]}
        for key,value in mapping.items():
            self.result_labels[key].config(text=f"€ {value:.2f}" if value is not None else "—")
