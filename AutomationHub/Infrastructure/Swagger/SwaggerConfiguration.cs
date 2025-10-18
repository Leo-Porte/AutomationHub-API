using System.Reflection;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;

namespace AutomationHub.Infrastructure.Swagger
{
    /// <summary>
    /// Swagger configuration extensions for service collection and application pipeline.
    /// </summary>
    public static class SwaggerConfiguration
    {
        /// <summary>
        /// Adds Swagger services and configuration to the service collection, including XML comments.
        /// </summary>
        /// <param name="services">The current service collection.</param>
        /// <returns>The modified service collection.</returns>
        public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
        {
            services.AddEndpointsApiExplorer();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "AutomationHub API",
                    Version = "v1",
                    Description = "API for AutomationHub"
                });

                // Include XML comments
                var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
                var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
                if (File.Exists(xmlPath))
                {
                    c.IncludeXmlComments(xmlPath, includeControllerXmlComments: true);
                }
            });

            return services;
        }

        /// <summary>
        /// Enables Swagger middleware for development environments.
        /// </summary>
        /// <param name="app">The current application builder.</param>
        /// <returns>The application builder for chaining.</returns>
        public static IApplicationBuilder UseSwaggerDocumentation(this IApplicationBuilder app)
        {
            var env = app.ApplicationServices.GetRequiredService<IHostEnvironment>();
            if (env.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            return app;
        }
    }
}
