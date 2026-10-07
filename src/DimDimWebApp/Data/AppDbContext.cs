using DimDimWebApp.Models;
using Microsoft.EntityFrameworkCore;
namespace DimDimWebApp.Data;
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Cliente> Clientes => Set<Cliente>();
    public DbSet<Conta> Contas => Set<Conta>();
    protected override void OnModelCreating(ModelBuilder m)
    {
        m.Entity<Cliente>().ToTable("Clientes");
        m.Entity<Cliente>().HasIndex(x => x.Cpf).IsUnique();
        m.Entity<Conta>().ToTable("Contas");
        m.Entity<Conta>().HasIndex(x => x.Numero).IsUnique();
        m.Entity<Conta>().Property(x => x.Saldo).HasPrecision(18, 2);
        m.Entity<Conta>().HasOne(x => x.Cliente).WithMany(x => x.Contas)
            .HasForeignKey(x => x.ClienteId).OnDelete(DeleteBehavior.Restrict);
    }
}
