using System.ComponentModel.DataAnnotations;
namespace DimDimWebApp.Models;
public class Cliente
{
    public int Id { get; set; }
    [Required(ErrorMessage = "Informe o nome."), StringLength(100)] public string Nome { get; set; } = "";
    [Required(ErrorMessage = "Informe o e-mail."), EmailAddress, StringLength(150)] public string Email { get; set; } = "";
    [Required(ErrorMessage = "Informe o CPF com 11 dígitos."), RegularExpression(@"^\d{11}$", ErrorMessage = "Use 11 dígitos, sem pontuação."), StringLength(11)] public string Cpf { get; set; } = "";
    public List<Conta> Contas { get; set; } = new();
}
