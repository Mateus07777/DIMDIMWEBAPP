using System.ComponentModel.DataAnnotations;
namespace DimDimWebApp.Models;
public class Conta
{
    public int Id { get; set; }
    [Required, StringLength(20), RegularExpression(@"^[0-9-]{3,20}$", ErrorMessage = "Use de 3 a 20 dígitos ou hífens.")] public string Numero { get; set; } = "";
    [Required, RegularExpression("^(Corrente|Poupança)$")] public string Tipo { get; set; } = "Corrente";
    [Range(typeof(decimal), "0", "9999999999999999.99", ParseLimitsInInvariantCulture = true, ErrorMessage = "Informe um saldo não negativo.")] public decimal Saldo { get; set; }
    [Display(Name = "Cliente"), Range(1, int.MaxValue, ErrorMessage = "Selecione um cliente.")] public int ClienteId { get; set; }
    public Cliente? Cliente { get; set; }
}

