using DimDimWebApp.Data;
using DimDimWebApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace DimDimWebApp.Controllers;
public class ClientesController(AppDbContext db, ILogger<ClientesController> logger) : Controller
{
    
    public async Task<IActionResult> Index() => View(await db.Clientes.AsNoTracking().OrderBy(x => x.Id).ToListAsync());
    public async Task<IActionResult> Details(int id)
    {
        var item = await db.Clientes.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        return item == null ? NotFound() : View(item);
    }
    public async Task<IActionResult> Create() {  await Task.CompletedTask; return View(new Cliente()); }
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create([Bind("Nome,Email,Cpf")] Cliente item)
    {
        if (await db.Clientes.AnyAsync(x => x.Cpf == item.Cpf && x.Id != item.Id)) ModelState.AddModelError("Cpf", "CPF já cadastrado.");
        if (ModelState.IsValid)
        {
            try { db.Clientes.Add(item); await db.SaveChangesAsync(); logger.LogInformation("CRUD Clientes CREATE Id={Id}", item.Id); TempData["Sucesso"] = "Registro criado."; return RedirectToAction(nameof(Index)); }
            catch (DbUpdateException) { ModelState.AddModelError("", "Não foi possível salvar. Confira os valores e tente novamente."); }
        }
         return View(item);
    }
    public async Task<IActionResult> Edit(int id)
    {
        var item = await db.Clientes.FindAsync(id);
        if (item == null) return NotFound();
         return View(item);
    }
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, [Bind("Id,Nome,Email,Cpf")] Cliente item)
    {
        if (id != item.Id) return BadRequest();
        var original = await db.Clientes.FindAsync(id);
        if (original == null) return NotFound();
        if (await db.Clientes.AnyAsync(x => x.Cpf == item.Cpf && x.Id != item.Id)) ModelState.AddModelError("Cpf", "CPF já cadastrado.");
        if (ModelState.IsValid)
        {
            original.Nome = item.Nome;
            original.Email = item.Email;
            original.Cpf = item.Cpf;
            try { await db.SaveChangesAsync(); logger.LogInformation("CRUD Clientes UPDATE Id={Id}", id); TempData["Sucesso"] = "Registro atualizado."; return RedirectToAction(nameof(Index)); }
            catch (DbUpdateException) { ModelState.AddModelError("", "Não foi possível atualizar. Confira os valores e tente novamente."); }
        }
         return View(item);
    }
    public async Task<IActionResult> Delete(int id)
    {
        var item = await db.Clientes.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        return item == null ? NotFound() : View(item);
    }
    [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var item = await db.Clientes.FindAsync(id);
        if (item == null) return NotFound();
        if (await db.Contas.AnyAsync(x => x.ClienteId == id)) { TempData["Aviso"] = "Exclua as contas deste cliente antes de excluí-lo."; return RedirectToAction(nameof(Index)); }
        try { db.Clientes.Remove(item); await db.SaveChangesAsync(); logger.LogInformation("CRUD Clientes DELETE Id={Id}", id); TempData["Sucesso"] = "Registro excluído."; }
        catch (DbUpdateException) { TempData["Aviso"] = "Não foi possível excluir. Verifique relacionamentos e tente novamente."; }
        return RedirectToAction(nameof(Index));
    }
}
