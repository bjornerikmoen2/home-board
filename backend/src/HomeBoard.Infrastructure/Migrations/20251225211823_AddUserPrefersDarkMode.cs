using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeBoard.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddUserPrefersDarkMode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "PrefersDarkMode",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PrefersDarkMode",
                table: "Users");
        }
    }
}
