using DimDimWebApp.Data;
using DimDimWebApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace DimDimWebApp.Controllers;
public class ContasController(AppDbContext db, ILogger<ContasController> logger) : Controller
{
    private async Task Preparar(Conta? conta = null) => ViewBag.ClienteId = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(await db.Clientes.OrderBy(x => x.Nome).ToListAsync(), "Id", "Nome", conta?.ClienteId);
    public async Task<IActionResult> Index() => View(await db.Contas.Include(x => x.Cliente).AsNoTracking().OrderBy(x => x.Id).ToListAsync());
    public async Task<IActionResult> Details(int id)
    {
        var item = await db.Contas.Include(x => x.Cliente).AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        return item == null ? NotFound() : View(item);
    }
    public async Task<IActionResult> Create() { await Preparar(); await Task.CompletedTask; return View(new Conta()); }
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create([Bind("Numero,Tipo,Saldo,ClienteId")] Conta item)
    {
        if (!await db.Clientes.AnyAsync(x => x.Id == item.ClienteId)) ModelState.AddModelError("ClienteId", "Cliente inexistente.");
        if (await db.Contas.AnyAsync(x => x.Numero == item.Numero && x.Id != item.Id)) ModelState.AddModelError("Numero", "Número de conta já cadastrado.");
        if (ModelState.IsValid)
        {
            try { db.Contas.Add(item); await db.SaveChangesAsync(); logger.LogInformation("CRUD Contas CREATE Id={Id}", item.Id); TempData["Sucesso"] = "Registro criado."; return RedirectToAction(nameof(Index)); }
            catch (DbUpdateException) { ModelState.AddModelError("", "Não foi possível salvar. Confira os valores e tente novamente."); }
        }
        await Preparar(item); return View(item);
    }
    public async Task<IActionResult> Edit(int id)
    {
        var item = await db.Contas.FindAsync(id);
        if (item == null) return NotFound();
        await Preparar(item); return View(item);
    }
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, [Bind("Id,Numero,Tipo,Saldo,ClienteId")] Conta item)
    {
        if (id != item.Id) return BadRequest();
        var original = await db.Contas.FindAsync(id);
        if (original == null) return NotFound();
        if (!await db.Clientes.AnyAsync(x => x.Id == item.ClienteId)) ModelState.AddModelError("ClienteId", "Cliente inexistente.");
        if (await db.Contas.AnyAsync(x => x.Numero == item.Numero && x.Id != item.Id)) ModelState.AddModelError("Numero", "Número de conta já cadastrado.");
        if (ModelState.IsValid)
        {
            original.Numero = item.Numero;
            original.Tipo = item.Tipo;
            original.Saldo = item.Saldo;
            original.ClienteId = item.ClienteId;
            try { await db.SaveChangesAsync(); logger.LogInformation("CRUD Contas UPDATE Id={Id}", id); TempData["Sucesso"] = "Registro atualizado."; return RedirectToAction(nameof(Index)); }
            catch (DbUpdateException) { ModelState.AddModelError("", "Não foi possível atualizar. Confira os valores e tente novamente."); }
        }
        await Preparar(item); return View(item);
    }
    public async Task<IActionResult> Delete(int id)
    {
        var item = await db.Contas.Include(x => x.Cliente).AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        return item == null ? NotFound() : View(item);
    }
    [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var item = await db.Contas.FindAsync(id);
        if (item == null) return NotFound();
        
        try { db.Contas.Remove(item); await db.SaveChangesAsync(); logger.LogInformation("CRUD Contas DELETE Id={Id}", id); TempData["Sucesso"] = "Registro excluído."; }
        catch (DbUpdateException) { TempData["Aviso"] = "Não foi possível excluir. Verifique relacionamentos e tente novamente."; }
        return RedirectToAction(nameof(Index));
    }
}
