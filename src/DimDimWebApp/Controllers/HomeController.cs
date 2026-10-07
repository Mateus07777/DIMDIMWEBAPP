using DimDimWebApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace DimDimWebApp.Controllers;
public class HomeController(AppDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        ViewBag.Clientes = await db.Clientes.CountAsync();
        ViewBag.Contas = await db.Contas.CountAsync();
        ViewBag.Saldo = await db.Contas.SumAsync(x => (decimal?)x.Saldo) ?? 0m;
        return View();
    }
    public IActionResult Error() => View();
}
