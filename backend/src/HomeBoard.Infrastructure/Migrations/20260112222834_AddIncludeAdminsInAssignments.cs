using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeBoard.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddIncludeAdminsInAssignments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IncludeAdminsInAssignments",
                table: "FamilySettings",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IncludeAdminsInAssignments",
                table: "FamilySettings");
        }
    }
}
